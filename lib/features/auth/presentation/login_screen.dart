import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_logo.dart';
import '../../../shared/models/client_type.dart';
import '../../../l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.authInvalidCredentials)));
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
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        closeAuthWithoutLogin(context, ref);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: _LoginBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(32, 54, 32, 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LoginLogo(),
                          const SizedBox(height: 26),
                          Text(
                            l10n.authWelcome,
                            textAlign: TextAlign.center,
                            style: HeynTextStyles.sectionTitle.copyWith(
                              color: AppColors.darkText,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authWelcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: HeynTextStyles.subtitle.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _FieldLabel(l10n.authPhoneNumber),
                          const SizedBox(height: 8),
                          _PhoneLoginField(controller: _phoneController),
                          const SizedBox(height: 18),
                          _FieldLabel(l10n.authPassword),
                          const SizedBox(height: 8),
                          _PasswordLoginField(
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            onToggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onSubmitted: (_) => _isLoading ? null : _submit(),
                            tooltip: _obscurePassword
                                ? l10n.authShowPassword
                                : l10n.authHidePassword,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.authVerificationCodeLogin,
                                style: HeynTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LoginPrimaryButton(
                            label: l10n.authLogin,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 22),
                          _OrDivider(label: l10n.authOr),
                          const SizedBox(height: 22),
                          _CreateAccountButton(
                            label: l10n.authCreateNewAccount,
                            onPressed: _openRegister,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            l10n.authLegalText,
                            textAlign: TextAlign.center,
                            style: HeynTextStyles.caption.copyWith(
                              color: AppColors.mutedText,
                              fontSize: 10.5,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Opacity(
                            opacity: 0.92,
                            child: AuthClientTypeToggle(
                              selected: _selectedType,
                              onSelected: _selectType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _LoginTopActions(
                  skipLabel: l10n.authSkip,
                  onSkip: () => skipAuthToHome(context, ref),
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
  color: AppColors.darkText,
);

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.scaffoldBackground),
        PositionedDirectional(
          top: -92,
          end: -92,
          child: _LoginBlob(
            size: 210,
            color: AppColors.lightTeal.withValues(alpha: 0.72),
          ),
        ),
        PositionedDirectional(
          bottom: -72,
          start: -88,
          child: _LoginBlob(
            size: 250,
            color: HeynColors.turquoise.withValues(alpha: 0.12),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: const _LoginWavePainter())),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _LoginBlob extends StatelessWidget {
  const _LoginBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _LoginWavePainter extends CustomPainter {
  const _LoginWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = HeynColors.turquoise.withValues(alpha: 0.055);
    final path = Path()
      ..moveTo(0, size.height * 0.86)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.80,
        size.width * 0.58,
        size.height * 0.94,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        HeynLogoMark.logoPath,
        width: 68,
        height: 68,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.start,
      style: HeynTextStyles.caption.copyWith(
        color: AppColors.darkText,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LoginInputFrame extends StatelessWidget {
  const _LoginInputFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PhoneLoginField extends StatelessWidget {
  const _PhoneLoginField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _LoginInputFrame(
        child: Row(
          children: [
            const SizedBox(width: 13),
            const Icon(
              Icons.phone_outlined,
              color: AppColors.secondaryText,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              AuthSessionController.countryPrefix,
              style: HeynTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: AppColors.divider,
            ),
            Expanded(
              child: TextField(
                key: const Key('auth-phone'),
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: _fieldStyle.copyWith(fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordLoginField extends StatelessWidget {
  const _PasswordLoginField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.onSubmitted,
    required this.tooltip,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String> onSubmitted;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _LoginInputFrame(
        child: Row(
          children: [
            IconButton(
              tooltip: tooltip,
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.secondaryText,
                size: 19,
              ),
            ),
            Expanded(
              child: TextField(
                key: const Key('auth-password'),
                controller: controller,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: onSubmitted,
                style: _fieldStyle.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 14),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.secondaryText,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPrimaryButton extends StatelessWidget {
  const _LoginPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: HeynTextStyles.button.copyWith(fontSize: 14),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: HeynTextStyles.button.copyWith(fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LoginTopActions extends StatelessWidget {
  const _LoginTopActions({required this.skipLabel, required this.onSkip});

  final String skipLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          PositionedDirectional(
            top: 4,
            start: 12,
            child: _SubtleCircleAction(
              key: const Key('login-back'),
              icon: Icons.arrow_back_rounded,
              onTap: onSkip,
            ),
          ),
          PositionedDirectional(
            top: 4,
            end: 12,
            child: TextButton(
              key: const Key('auth-skip'),
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.padded,
                textStyle: HeynTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              child: Text(skipLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleCircleAction extends StatelessWidget {
  const _SubtleCircleAction({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.secondaryText, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.58),
        minimumSize: const Size.square(44),
      ),
    );
  }
}
