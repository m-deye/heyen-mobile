import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fond login : dégradé violet, vagues lumineuses, particules.
class NightAtmosphere extends StatelessWidget {
  const NightAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B2D5C),
                Color(0xFF071C3A),
                AppColors.primaryDark,
                Color(0xFF1AA8B0),
              ],
            ),
          ),
        ),
        CustomPaint(painter: _WavesPainter()),
        CustomPaint(painter: _ParticlesPainter()),
        _Glow(
          alignment: Alignment(-0.85, -0.7),
          size: 280,
          color: AppColors.primary,
        ),
        _Glow(
          alignment: Alignment(0.9, -0.2),
          size: 220,
          color: Color(0xFF60A5FA),
        ),
        _Glow(
          alignment: Alignment(-0.4, 0.85),
          size: 260,
          color: AppColors.gold,
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.08);

    for (var i = 0; i < 4; i++) {
      final path = Path();
      final y = size.height * (0.35 + i * 0.14);
      path.moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 8) {
        final wave =
            math.sin((x / size.width * math.pi * 2) + i) * (18 + i * 6);
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlesPainter extends CustomPainter {
  const _ParticlesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..color = AppColors.gold.withValues(alpha: 0.35);
    for (var i = 0; i < 42; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble() * 1.8 + 0.4;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
