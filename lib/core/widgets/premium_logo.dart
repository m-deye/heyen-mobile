import 'package:flutter/material.dart';

import '../../theme/heyn_colors.dart';
import '../theme/app_text_styles.dart';

class HeynLogoMark extends StatelessWidget {
  const HeynLogoMark({super.key, this.size = 44, this.iconSize});

  static const logoPath = 'assets/images/heyn_logo.png';

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HeynColors.navy,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: HeynColors.turquoise, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: Image.asset(
          logoPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.shopping_bag_outlined,
            size: iconSize ?? size * 0.48,
            color: HeynColors.turquoise,
          ),
        ),
      ),
    );
  }
}

class PremiumLogo extends StatelessWidget {
  const PremiumLogo({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Heyn',
      textAlign: TextAlign.center,
      style: AppTextStyles.title.copyWith(fontSize: fontSize, height: 1),
    );
  }
}
