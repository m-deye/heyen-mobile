import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_connection.dart';
import '../../../core/api/api_unreachable.dart';
import '../../../core/dev/dev_seed_data.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/user.dart';
import '../data/auth_api.dart';

enum AuthStatus { guest, authenticated }

enum LoginAttemptResult { success, invalidCredentials, accountNotFound }

final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, User?>(AuthSessionController.new);

/// Guest = no session user (local demo has no token; API sessions store tokens).
/// Authenticated = a session user is set after a successful login/register.
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authSessionControllerProvider) == null
      ? AuthStatus.guest
      : AuthStatus.authenticated;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authStatusProvider) == AuthStatus.guest;
});

final currentClientTypeProvider = Provider<ClientType>((ref) {
  return ref.watch(authSessionControllerProvider)?.type ??
      ClientType.particulier;
});

class _LocalAccount {
  const _LocalAccount({
    required this.phone,
    required this.password,
    required this.user,
  });

  final String phone;
  final String password;
  final User user;
}

class AuthSessionController extends Notifier<User?> {
  static const countryPrefix = '+222';
  static const testPhone = '12345678';
  static const testPassword = '123456';
  static const merchantTestPhone = '87654321';
  static const merchantTestPassword = '123456';

  final List<_LocalAccount> _registeredAccounts = [];

  @override
  User? build() => null;

  Future<bool> login({required String phone, required String password}) async {
    final result = await loginAttempt(phone: phone, password: password);
    return result == LoginAttemptResult.success;
  }

  /// Calls existing POST /api/auth/login without changing its contract.
  /// Distinguishes unknown accounts from bad passwords for guest-sheet errors.
  Future<LoginAttemptResult> loginAttempt({
    required String phone,
    required String password,
  }) async {
    final localPhone = _normalizedLocalPhone(phone);
    final trimmedPassword = password.trim();
    final formattedPhone = '$countryPrefix$localPhone';

    if (ref.read(apiConfigProvider).isConfigured) {
      try {
        final session = await AuthApi(
          ref.read(dioProvider),
          ref.read(authTokenStoreProvider),
        ).login(phone: formattedPhone, password: trimmedPassword);
        state = _overlayDemoAccount(session.user, localPhone);
        _markSession(fromApi: true);
        return LoginAttemptResult.success;
      } on DioException catch (error) {
        if (isApiUnreachable(error)) {
          return _localLoginResult(localPhone, trimmedPassword);
        }
        if (_isAccountNotFoundMessage(_dioMessage(error))) {
          return LoginAttemptResult.accountNotFound;
        }
        final local = _localLoginResult(localPhone, trimmedPassword);
        if (local == LoginAttemptResult.success) {
          return local;
        }
        return LoginAttemptResult.invalidCredentials;
      } catch (_) {
        return _localLoginResult(localPhone, trimmedPassword);
      }
    }

    return _localLoginResult(localPhone, trimmedPassword);
  }

  Future<String?> register({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    required ClientType type,
    String shopName = '',
  }) async {
    final name = fullName.trim();
    final localPhone = _normalizedLocalPhone(phone);
    final trimmedPassword = password.trim();
    final trimmedConfirm = confirmPassword.trim();
    final trimmedShop = shopName.trim();

    if (name.length < 2) {
      return 'Indiquez votre nom complet.';
    }

    if (localPhone.length != testPhone.length) {
      return 'Indiquez un numéro mauritanien à 8 chiffres.';
    }

    if (trimmedPassword != trimmedConfirm) {
      return 'Les mots de passe ne correspondent pas.';
    }

    if (type.isCommercant && trimmedShop.length < 2) {
      return 'Indiquez le nom de votre boutique.';
    }

    final formattedPhone = '$countryPrefix$localPhone';
    if (ref.read(apiConfigProvider).isConfigured) {
      if (trimmedPassword.length < 8) {
        return 'Le mot de passe doit contenir au moins 8 caractères.';
      }

      final parts = name.split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1
          ? parts.sublist(1).join(' ')
          : firstName;
      if (lastName.length < 2) {
        return 'Indiquez votre nom et prénom.';
      }

      try {
        final session =
            await AuthApi(
              ref.read(dioProvider),
              ref.read(authTokenStoreProvider),
            ).register(
              firstName: firstName,
              lastName: lastName,
              email: '$localPhone@heyn.app',
              phone: formattedPhone,
              password: trimmedPassword,
            );
        state = _overlayDemoAccount(
          session.user.copyWith(type: type, shopName: trimmedShop),
          localPhone,
        );
        _markSession(fromApi: true);
        return null;
      } on DioException catch (error) {
        if (isApiUnreachable(error)) {
          return _localRegister(
            name: name,
            localPhone: localPhone,
            password: trimmedPassword,
            type: type,
            shopName: trimmedShop,
          );
        }
        return _dioMessage(error);
      } catch (_) {
        return 'Impossible de créer le compte.';
      }
    }

    if (trimmedPassword.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }

    return _localRegister(
      name: name,
      localPhone: localPhone,
      password: trimmedPassword,
      type: type,
      shopName: trimmedShop,
    );
  }

  Future<void> logout() async {
    if (ref.read(apiConfigProvider).isConfigured) {
      try {
        await AuthApi(
          ref.read(dioProvider),
          ref.read(authTokenStoreProvider),
        ).logout();
      } catch (_) {}
    }
    state = null;
    _markSession(fromApi: false);
  }

  User _overlayDemoAccount(User user, String localPhone) {
    if (localPhone == merchantTestPhone) {
      return user.copyWith(
        type: ClientType.commercant,
        shopName: user.shopName.isNotEmpty
            ? user.shopName
            : DevSeedData.commercantUser.shopName,
        fullName: user.fullName.isNotEmpty
            ? user.fullName
            : DevSeedData.commercantUser.fullName,
      );
    }
    return user;
  }

  bool _localLogin(String localPhone, String trimmedPassword) {
    return _localLoginResult(localPhone, trimmedPassword) ==
        LoginAttemptResult.success;
  }

  LoginAttemptResult _localLoginResult(
    String localPhone,
    String trimmedPassword,
  ) {
    if (localPhone == testPhone && trimmedPassword == testPassword) {
      state = DevSeedData.particulierUser;
      _markSession(fromApi: false);
      return LoginAttemptResult.success;
    }

    if (localPhone == merchantTestPhone &&
        trimmedPassword == merchantTestPassword) {
      state = DevSeedData.commercantUser;
      _markSession(fromApi: false);
      return LoginAttemptResult.success;
    }

    for (final account in _registeredAccounts) {
      if (account.phone == localPhone && account.password == trimmedPassword) {
        state = account.user;
        _markSession(fromApi: false);
        return LoginAttemptResult.success;
      }
    }

    if (_isKnownLocalPhone(localPhone)) {
      return LoginAttemptResult.invalidCredentials;
    }
    return LoginAttemptResult.accountNotFound;
  }

  bool _isKnownLocalPhone(String localPhone) {
    return localPhone == testPhone ||
        localPhone == merchantTestPhone ||
        _registeredAccounts.any((account) => account.phone == localPhone);
  }

  bool _isAccountNotFoundMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('introuvable') ||
        normalized.contains('inexistant') ||
        normalized.contains("n'existe") ||
        normalized.contains('not found') ||
        normalized.contains('unknown user') ||
        normalized.contains('no user') ||
        normalized.contains('compte inconnu');
  }

  String? _localRegister({
    required String name,
    required String localPhone,
    required String password,
    required ClientType type,
    required String shopName,
  }) {
    if (localPhone == testPhone ||
        localPhone == merchantTestPhone ||
        _registeredAccounts.any((account) => account.phone == localPhone)) {
      return 'Ce numéro est déjà utilisé.';
    }

    final user = User(
      id: 'local-$localPhone',
      fullName: name,
      type: type,
      phone: '$countryPrefix$localPhone',
      shopName: type.isCommercant ? shopName : '',
    );

    _registeredAccounts.add(
      _LocalAccount(phone: localPhone, password: password, user: user),
    );
    state = user;
    _markSession(fromApi: false);
    return null;
  }

  void _markSession({required bool fromApi}) {
    if (fromApi) {
      ref.read(sessionFromApiProvider.notifier).markRemote();
    } else {
      ref.read(sessionFromApiProvider.notifier).markLocal();
    }
  }

  String _normalizedLocalPhone(String value) {
    final phoneDigits = value.trim().replaceAll(RegExp(r'\D'), '');

    if (phoneDigits.startsWith(_countryPrefixDigits) &&
        phoneDigits.length == _countryPrefixDigits.length + testPhone.length) {
      return phoneDigits.substring(_countryPrefixDigits.length);
    }

    return phoneDigits;
  }

  static String get _countryPrefixDigits =>
      countryPrefix.replaceAll(RegExp(r'\D'), '');

  String _dioMessage(
    DioException error, {
    String fallback = 'Impossible de créer le compte.',
  }) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }

  Future<String?> requestPasswordReset({required String email}) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return 'Indiquez une adresse email valide.';
    }
    if (!ref.read(apiConfigProvider).isConfigured) {
      return 'Le serveur Heyen n\'est pas disponible.';
    }
    try {
      await AuthApi(
        ref.read(dioProvider),
        ref.read(authTokenStoreProvider),
      ).requestPasswordReset(email: trimmed);
      return null;
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return 'Le serveur Heyen n\'est pas disponible.';
      }
      return _dioMessage(error, fallback: 'Impossible d\'envoyer le lien.');
    } catch (_) {
      return 'Impossible d\'envoyer le lien.';
    }
  }

  Future<String?> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedToken = token.trim();
    final trimmedPassword = password.trim();
    if (trimmedToken.length < 10) {
      return 'Collez le code reçu par email (ou dans la console du serveur).';
    }
    if (trimmedPassword.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    if (trimmedPassword != confirmPassword.trim()) {
      return 'Les mots de passe ne correspondent pas.';
    }
    if (!ref.read(apiConfigProvider).isConfigured) {
      return 'Le serveur Heyen n\'est pas disponible.';
    }
    try {
      await AuthApi(
        ref.read(dioProvider),
        ref.read(authTokenStoreProvider),
      ).resetPassword(token: trimmedToken, password: trimmedPassword);
      return null;
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return 'Le serveur Heyen n\'est pas disponible.';
      }
      return _dioMessage(
        error,
        fallback: 'Impossible de réinitialiser le mot de passe.',
      );
    } catch (_) {
      return 'Impossible de réinitialiser le mot de passe.';
    }
  }
}
