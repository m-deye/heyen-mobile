import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../theme/heyn_theme.dart';
import '../application/auth_session_controller.dart';
import 'auth_chrome.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialToken = ''});

  final String initialToken;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    final error = await ref
        .read(authSessionControllerProvider.notifier)
        .resetPassword(
          token: _tokenController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    final l10n = AppLocalizations.of(context);
    if (error == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authPasswordResetSuccess)));
      context.go('/login');
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizedAuthError(error, l10n))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    HeynGoldTitle(l10n.authNewPasswordTitle, fontSize: 28),
                    const SizedBox(height: 10),
                    Text(
                      l10n.authNewPasswordSubtitle,
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
                              controller: _tokenController,
                              minLines: 2,
                              maxLines: 4,
                              style: const TextStyle(
                                color: HeynColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: authInputDecoration(
                                hintText: l10n.authCodeToken,
                                prefixIcon: const Icon(
                                  Icons.key_outlined,
                                  color: HeynColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AuthGlassField(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: HeynColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: authInputDecoration(
                                hintText: l10n.authNewPassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
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
                          const SizedBox(height: 12),
                          AuthGlassField(
                            child: TextField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _isLoading ? null : _submit(),
                              style: const TextStyle(
                                color: HeynColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: authInputDecoration(
                                hintText: l10n.authConfirm,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    );
                                  },
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: HeynColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AuthGradientButton(
                            label: l10n.commonSave,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n.commonBackToLogin,
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
