import 'package:flutter/material.dart';

import 'app_card.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppCard(padding: padding, margin: margin, child: child);
  }
}
