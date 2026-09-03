import 'package:flutter/material.dart';

import '../../theme/heyn_theme.dart';

class HeynSearchField extends StatelessWidget {
  const HeynSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Rechercher un produit',
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return HeynGlassBox(
      radius: 22,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: HeynTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: HeynTextStyles.subtitle,
          prefixIcon: const Icon(
            Icons.search,
            color: HeynColors.turquoise,
            size: 20,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Effacer',
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
