import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/heyn_colors.dart';
import '../application/auth_session_controller.dart';

enum GuestAuthStep { phoneStep, passwordStep }

enum GuestAuthSheetResult {
  authenticated,
  dismissed,
  forgotPassword,
  createAccount,
}

const _navy = HeynColors.navy;
const _turquoise = HeynColors.turquoise;
const _track = Color(0xFFE5E7EB);
const _muted = Color(0xFF6B7280);
const _switchDuration = Duration(milliseconds: 300);

Future<GuestAuthSheetResult?> showGuestAuthSheet(BuildContext context) {
  return showModalBottomSheet<GuestAuthSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const GuestAuthSheet(),
      );
    },
  );
}

class GuestAuthSheet extends ConsumerStatefulWidget {
  const GuestAuthSheet({super.key});

  @override
  ConsumerState<GuestAuthSheet> createState() => _GuestAuthSheetState();
}

class _GuestAuthSheetState extends ConsumerState<GuestAuthSheet> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  GuestAuthStep _step = GuestAuthStep.phoneStep;
  var _obscurePassword = true;
  var _isLoading = false;
  String? _inlineError;

  bool get _phoneComplete => _digitsOf(_phoneController.text).length == 8;

  String get _localPhone => _digitsOf(_phoneController.text);

  String get _formattedPhone {
    final digits = _localPhone.padRight(8);
    final shown = _localPhone;
    if (shown.length != 8) {
      return '${AuthSessionController.countryPrefix} $shown';
    }
    return '${AuthSessionController.countryPrefix} ${digits.substring(0, 2)} '
        '${digits.substring(2, 4)} ${digits.substring(4, 6)} '
        '${digits.substring(6, 8)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String _digitsOf(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    const prefix = '222';
    if (digits.startsWith(prefix) && digits.length >= prefix.length + 8) {
      digits = digits.substring(digits.length - 8);
    } else if (digits.startsWith(prefix) && digits.length > 8) {
      digits = digits.substring(prefix.length);
    }
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    return digits;
  }

  void _goTo(GuestAuthStep step) {
    setState(() {
      _step = step;
      _inlineError = null;
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      switch (step) {
        case GuestAuthStep.phoneStep:
          _phoneFocus.requestFocus();
        case GuestAuthStep.passwordStep:
          _passwordFocus.requestFocus();
      }
    });
  }

  Future<void> _continueFromPhone() async {
    if (!_phoneComplete || _isLoading) {
      return;
    }
    _goTo(GuestAuthStep.passwordStep);
  }

  Future<void> _submitPassword() async {
    if (_isLoading || _passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _inlineError = null;
    });

    final result = await ref
        .read(authSessionControllerProvider.notifier)
        .loginAttempt(
          phone: _localPhone,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case LoginAttemptResult.success:
        Navigator.of(context).pop(GuestAuthSheetResult.authenticated);
      case LoginAttemptResult.invalidCredentials:
      case LoginAttemptResult.accountNotFound:
        setState(() {
          _isLoading = false;
          _inlineError = 'Identifiants incorrects.';
        });
        _passwordFocus.requestFocus();
    }
  }

  void _popWith(GuestAuthSheetResult result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDF4F7),
            Color(0xFFF7FAFC),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _track,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                key: const Key('login-back'),
                tooltip: 'Fermer',
                onPressed: () => _popWith(GuestAuthSheetResult.dismissed),
                icon: const Icon(Icons.close, color: _navy),
              ),
            ),
            _ProgressBars(complete: _step != GuestAuthStep.phoneStep),
            const SizedBox(height: 22),
            AnimatedSize(
              duration: _switchDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _step == GuestAuthStep.phoneStep
                  ? const SizedBox.shrink()
                  : _CompactPhoneSummary(
                      phone: _formattedPhone,
                      onEdit: () => _goTo(GuestAuthStep.phoneStep),
                    ),
            ),
            AnimatedSwitcher(
              duration: _switchDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_step.name),
                child: switch (_step) {
                  GuestAuthStep.phoneStep => _PhoneStep(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    complete: _phoneComplete,
                    isLoading: _isLoading,
                    onChanged: (_) => setState(() => _inlineError = null),
                    onContinue: _continueFromPhone,
                  ),
                  GuestAuthStep.passwordStep => _PasswordStep(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscure: _obscurePassword,
                    isLoading: _isLoading,
                    error: _inlineError,
                    onToggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onChanged: (_) => setState(() => _inlineError = null),
                    onForgot: () => _popWith(GuestAuthSheetResult.forgotPassword),
                    onSubmit: _submitPassword,
                  ),
                },
              ),
            ),
            const SizedBox(height: 18),
            _CreateAccountLink(
              onTap: () => _popWith(GuestAuthSheetResult.createAccount),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _Bar(filled: true)),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedContainer(
            duration: _switchDuration,
            height: 3,
            decoration: BoxDecoration(
              color: complete ? _navy : _track,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: filled ? _navy : _track,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CompactPhoneSummary extends StatelessWidget {
  const _CompactPhoneSummary({required this.phone, required this.onEdit});

  final String phone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              phone,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _navy,
              ),
            ),
          ),
          IconButton(
            key: const Key('guest-auth-edit-phone'),
            tooltip: 'Modifier le numéro',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18, color: _navy),
          ),
        ],
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.controller,
    required this.focusNode,
    required this.complete,
    required this.isLoading,
    required this.onChanged,
    required this.onContinue,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool complete;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quel est votre numéro ?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: _navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'On vérifiera si vous avez déjà un compte Heyn',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _muted,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HeynColors.borderGold, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                AuthSessionController.countryPrefix,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _turquoise,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1.2, height: 26, color: HeynColors.borderGold),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('guest-auth-phone'),
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: const [_PhoneDigitsFormatter()],
                  onChanged: onChanged,
                  onSubmitted: (_) => onContinue(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '00 00 00 00',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _muted.withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SheetButton(
          key: const Key('guest-auth-continue'),
          label: 'Continuer',
          enabled: complete && !isLoading,
          isLoading: isLoading,
          onPressed: onContinue,
        ),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.isLoading,
    required this.error,
    required this.onToggleObscure,
    required this.onChanged,
    required this.onForgot,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final bool isLoading;
  final String? error;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onForgot;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Entrez votre mot de passe',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: _navy,
          ),
        ),
        const SizedBox(height: 24),
        _UnderlineField(
          key: const Key('guest-auth-password'),
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmit(),
          hint: 'Votre mot de passe',
          suffix: IconButton(
            tooltip: obscure
                ? 'Afficher le mot de passe'
                : 'Masquer le mot de passe',
            onPressed: onToggleObscure,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _muted,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HeynColors.danger,
            ),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgot,
            child: Text(
              'Mot de passe oublié ?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _SheetButton(
          label: 'Se connecter',
          enabled: controller.text.isNotEmpty && !isLoading,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _CreateAccountLink extends StatelessWidget {
  const _CreateAccountLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: _muted,
          ),
        ),
        TextButton(
          key: const Key('guest-auth-create-account'),
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Créer un compte',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _turquoise,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.suffix,
    this.autofocus = false,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final Widget? suffix;
  final bool autofocus;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: _navy,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: textStyle,
      cursorColor: _navy,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textStyle.copyWith(
          color: _muted.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffix,
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.only(bottom: 10, top: 6),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: _navy, width: 1.4),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _navy, width: 1.4),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _navy, width: 2),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF0B2D5C), Color(0xFF1AA8B0)],
                )
              : null,
          color: enabled ? null : _navy.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(99),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }
}

class _PhoneDigitsFormatter extends TextInputFormatter {
  const _PhoneDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('222') && digits.length >= 11) {
      digits = digits.substring(digits.length - 8);
    } else if (digits.startsWith('222') && digits.length > 8) {
      digits = digits.substring(3);
    }
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
