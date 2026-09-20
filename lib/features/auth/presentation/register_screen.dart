import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/client_type.dart';
import '../../../theme/heyn_theme.dart';
import '../application/auth_navigation.dart';
import '../application/auth_session_controller.dart';
import 'auth_chrome.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  ClientType _selectedType = ClientType.particulier;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _shopController.dispose();
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
        .register(
          fullName: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
          type: _selectedType,
          shopName: _shopController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (error == null) {
      completePostAuthNavigation(context, ref);
      return;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizedAuthError(error, l10n))));
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/login');
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: const Key('auth-skip'),
                        onPressed: () => skipAuthToHome(context, ref),
                        child: Text(
                          l10n.authSkip,
                          style: HeynTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const AuthLogoBadge(size: 96),
                    const SizedBox(height: 20),
                    HeynGoldTitle(l10n.authCreateYourAccount, fontSize: 28),
                    const SizedBox(height: 10),
                    Text(
                      l10n.authRegisterSubtitle,
                      textAlign: TextAlign.center,
                      style: HeynTextStyles.subtitle.copyWith(
                        color: HeynColors.nightPurple.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthGlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.authClientType,
                            style: HeynTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AuthClientTypeToggle(
                            selected: _selectedType,
                            onSelected: (type) {
                              setState(() => _selectedType = type);
                            },
                          ),
                          const SizedBox(height: 16),
                          _GlassTextField(
                            controller: _nameController,
                            hintText: l10n.authFullName,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          _GlassTextField(
                            controller: _phoneController,
                            hintText: '+222 87654321',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.phone_outlined,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: _selectedType.isCommercant
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: _GlassTextField(
                                      controller: _shopController,
                                      hintText: l10n.authShopName,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: Icons.storefront_outlined,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          _GlassTextField(
                            controller: _passwordController,
                            hintText: l10n.authPassword,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? l10n.authShowPassword
                                  : l10n.authHidePassword,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
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
                          const SizedBox(height: 12),
                          _GlassTextField(
                            controller: _confirmController,
                            hintText: l10n.authConfirmPassword,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _isLoading ? null : _submit(),
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirm
                                  ? l10n.authShowPassword
                                  : l10n.authHidePassword,
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: HeynColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthGradientButton(
                            label: l10n.authCreateMyAccount,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.authAlreadyHaveAccount,
                      textAlign: TextAlign.center,
                      style: HeynTextStyles.bodyMedium.copyWith(
                        color: HeynColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AuthOutlineButton(label: l10n.authLogin, onTap: _goToLogin),
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

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AuthGlassField(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        style: HeynTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        decoration: authInputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: HeynColors.goldDark),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
