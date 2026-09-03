import 'package:flutter/material.dart';

import 'gradient_button.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.goldBorder = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final bool goldBorder;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      expand: expand,
      goldBorder: goldBorder,
    );
  }
}
