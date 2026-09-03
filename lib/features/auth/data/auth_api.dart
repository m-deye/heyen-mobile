import 'package:dio/dio.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../core/api/auth_token_store.dart';
import '../../../shared/models/user.dart';

class AuthSessionPayload {
  const AuthSessionPayload({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
}

class AuthApi {
  const AuthApi(this._dio, this._tokens);

  final Dio _dio;
  final AuthTokenStore _tokens;

  Future<AuthSessionPayload> login({
    required String phone,
    required String password,
  }) {
    return _authenticate(ApiEndpoints.login, {
      'phone': phone,
      'password': password,
    });
  }

  Future<AuthSessionPayload> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _authenticate(ApiEndpoints.register, {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post<Object?>(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {}
    }
    await _tokens.clear();
  }

  Future<String> requestPasswordReset({required String email}) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim().toLowerCase()},
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final data = asJsonMap(unwrapApiData(response.data));
    final message = data['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) {
      return message;
    }
    return 'Si un compte existe avec cet email, un lien de réinitialisation vient d\'être envoyé.';
  }

  Future<String> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.resetPassword,
      data: {'token': token.trim(), 'password': password},
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final data = asJsonMap(unwrapApiData(response.data));
    final message = data['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) {
      return message;
    }
    return 'Mot de passe réinitialisé avec succès.';
  }

  Future<AuthSessionPayload> _authenticate(
    String path,
    Map<String, String> body,
  ) async {
    final response = await _dio.post<Object?>(
      path,
      data: body,
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final data = asJsonMap(unwrapApiData(response.data));
    final userJson = asJsonMap(data['user']);
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';
    if (userJson.isEmpty || accessToken.isEmpty || refreshToken.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: apiErrorMessage(response.data),
      );
    }

    await _tokens.save(accessToken: accessToken, refreshToken: refreshToken);
    return AuthSessionPayload(
      user: User.fromJson(userJson),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
