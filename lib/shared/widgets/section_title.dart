import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title.copyWith(fontSize: 18))),
        if (actionLabel != null)
          TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
      ],
    );
  }
}
