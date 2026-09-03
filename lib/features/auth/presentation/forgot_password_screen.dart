import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/heyn_theme.dart';
import '../application/auth_session_controller.dart';
import 'auth_chrome.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  var _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    final error = await ref
        .read(authSessionControllerProvider.notifier)
        .requestPasswordReset(email: _emailController.text);
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    if (error == null) {
      setState(() => _sent = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const AuthLogoBadge(size: 96),
                    const SizedBox(height: 20),
                    const HeynGoldTitle('Mot de passe oublié', fontSize: 28),
                    const SizedBox(height: 10),
                    Text(
                      'Indiquez l\'email de votre compte. En local, le lien s\'affiche dans le terminal de npm run dev.',
                      textAlign: TextAlign.center,
                      style: HeynTextStyles.subtitle.copyWith(
                        color: HeynColors.nightPurple.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthGlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthGlassField(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _isLoading ? null : _submit(),
                              style: HeynTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: authInputDecoration(
                                hintText: 'aminata@heyn.app',
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: HeynColors.goldDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_sent) ...[
                            const Text(
                              'Si un compte existe avec cet email, un lien de réinitialisation vient d\'être envoyé.',
                              style: TextStyle(
                                color: HeynColors.textDark,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          AuthGradientButton(
                            label: 'Envoyer le lien',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.push('/reset-password'),
                            child: const Text(
                              'J\'ai déjà un code',
                              style: TextStyle(
                                color: HeynColors.goldDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }
                        context.go('/login');
                      },
                      child: const Text(
                        'Retour à la connexion',
                        style: TextStyle(
                          color: HeynColors.goldDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
