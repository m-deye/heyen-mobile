import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/client_type.dart';
import '../../../theme/heyn_theme.dart';
import '../application/auth_navigation.dart';
import '../application/auth_session_controller.dart';
import 'auth_chrome.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(
    text: AuthSessionController.testPhone,
  );
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  ClientType _selectedType = ClientType.particulier;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectType(ClientType type) {
    setState(() {
      _selectedType = type;
      _phoneController.text = type.isCommercant
          ? AuthSessionController.merchantTestPhone
          : AuthSessionController.testPhone;
    });
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    final didLogin = await ref
        .read(authSessionControllerProvider.notifier)
        .login(
          phone: _phoneController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (didLogin) {
      completePostAuthNavigation(context, ref);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Identifiants incorrects.')));
  }

  void _openRegister() {
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
    if (redirect == null || redirect.isEmpty) {
      context.push('/register');
      return;
    }
    context.push('/register?redirect=${Uri.encodeQueryComponent(redirect)}');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        closeAuthWithoutLogin(context, ref);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      HeynRoundIconButton(
                        key: const Key('login-back'),
                        icon: Icons.arrow_back,
                        onTap: () => closeAuthWithoutLogin(context, ref),
                      ),
                      const Spacer(),
                      TextButton(
                        key: const Key('auth-skip'),
                        onPressed: () => skipAuthToHome(context, ref),
                        child: Text(
                          'Passer',
                          style: HeynTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          children: [
                            const AuthLogoBadge(),
                            const SizedBox(height: 22),
                            const HeynGoldTitle(
                              'Bienvenue sur Heyn',
                              fontSize: 30,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Connectez-vous pour suivre vos commandes et retrouver vos produits favoris',
                              textAlign: TextAlign.center,
                              style: HeynTextStyles.subtitle.copyWith(
                                color: HeynColors.nightPurple.withValues(
                                  alpha: 0.78,
                                ),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 28),
                            AuthGlassPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Type de client',
                                    style: HeynTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AuthClientTypeToggle(
                                    selected: _selectedType,
                                    onSelected: _selectType,
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Numéro de téléphone',
                                    style: HeynTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AuthGlassField(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      style: _fieldStyle,
                                      decoration: authInputDecoration(
                                        hintText: 'Entrez votre numéro',
                                        prefixIcon: const Icon(
                                          Icons.phone_outlined,
                                          color: HeynColors.goldDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Mot de passe',
                                    style: HeynTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AuthGlassField(
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) =>
                                          _isLoading ? null : _submit(),
                                      style: _fieldStyle,
                                      decoration: authInputDecoration(
                                        hintText: 'Votre mot de passe',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: HeynColors.goldDark,
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword
                                              ? 'Afficher le mot de passe'
                                              : 'Masquer le mot de passe',
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: HeynColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          context.push('/forgot-password'),
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: HeynTextStyles.caption.copyWith(
                                          color: HeynColors.goldDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AuthGradientButton(
                                    label: 'Continuer',
                                    isLoading: _isLoading,
                                    onPressed: _isLoading ? null : _submit,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Vous découvrez Heyn ?',
                              textAlign: TextAlign.center,
                              style: HeynTextStyles.bodyMedium.copyWith(
                                color: HeynColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AuthOutlineButton(
                              label: 'Créer un compte',
                              onTap: _openRegister,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _fieldStyle = HeynTextStyles.bodyMedium.copyWith(
  fontWeight: FontWeight.w600,
  color: HeynColors.nightPurple,
);
