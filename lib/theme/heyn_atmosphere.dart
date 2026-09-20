import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'heyn_colors.dart';

/// Fond crème / blanc teinté navy–turquoise.
class HeynPageBackdrop extends StatelessWidget {
  const HeynPageBackdrop({super.key, required this.child, this.silk = true});

  final Widget child;
  final bool silk;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF4FAFB),
                  Color(0xFFE4F2F4),
                  Color(0xFFD8E6F2),
                  Color(0xFFE8F6F7),
                ],
                stops: [0, 0.32, 0.68, 1],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _GlowBlob(color: const Color(0x661AA8B0), size: 220),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _GlowBlob(color: const Color(0x550B2D5C), size: 200),
        ),
        Positioned(
          bottom: 80,
          right: -50,
          child: _GlowBlob(color: const Color(0x441AA8B0), size: 240),
        ),
        if (silk)
          const Positioned.fill(
            child: CustomPaint(painter: _SilkWavesPainter()),
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SilkWavesPainter extends CustomPainter {
  const _SilkWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..color = const Color(0x181AA8B0);
    for (var i = 0; i < 8; i++) {
      final y = 30.0 + i * 92;
      final path = Path()..moveTo(-30, y);
      path.cubicTo(
        size.width * 0.25,
        y - 48,
        size.width * 0.7,
        y + 56,
        size.width + 30,
        y,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeynGoldTitle extends StatelessWidget {
  const HeynGoldTitle(this.text, {super.key, this.fontSize = 28});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: HeynColors.navy,
        height: 1.15,
      ),
    );
  }
}

class HeynProduceBasket extends StatelessWidget {
  const HeynProduceBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _BasketPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _BasketPainter extends CustomPainter {
  const _BasketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF4DC), Color(0xFFF6E7C1)],
        ).createShader(Offset.zero & size),
    );

    void fruit(Offset c, double r, Color color, Color shine) {
      canvas.drawCircle(c, r, Paint()..color = color);
      canvas.drawCircle(
        c.translate(-r * 0.28, -r * 0.28),
        r * 0.28,
        Paint()..color = shine.withValues(alpha: 0.45),
      );
    }

    fruit(Offset(cx - 28, cy - 38), 18, const Color(0xFFE85D3A), Colors.white);
    fruit(Offset(cx + 6, cy - 48), 16, const Color(0xFFF2A33A), Colors.white);
    fruit(Offset(cx + 32, cy - 30), 15, const Color(0xFFD94B4B), Colors.white);
    fruit(Offset(cx - 8, cy - 22), 14, const Color(0xFF7CB342), Colors.white);
    fruit(Offset(cx + 18, cy - 16), 12, const Color(0xFFFFCC80), Colors.white);

    final basket = Path()
      ..moveTo(cx - 62, cy - 8)
      ..quadraticBezierTo(cx - 70, cy + 48, cx, cy + 58)
      ..quadraticBezierTo(cx + 70, cy + 48, cx + 62, cy - 8)
      ..close();
    canvas.drawPath(basket, Paint()..color = const Color(0xFFC48A3A));
    canvas.drawPath(
      basket,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF8D5A1E),
    );
    for (var i = 0; i < 5; i++) {
      final x = cx - 40 + i * 20.0;
      canvas.drawLine(
        Offset(x, cy),
        Offset(cx + (x - cx) * 0.2, cy + 48),
        Paint()
          ..color = const Color(0x668D5A1E)
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeynCategoryScene extends StatelessWidget {
  const HeynCategoryScene({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CategoryScenePainter(categoryId),
      child: const SizedBox.expand(),
    );
  }
}

class HeynProductScene extends StatelessWidget {
  const HeynProductScene({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CategoryScenePainter(categoryId, compact: true),
      child: const SizedBox.expand(),
    );
  }
}

class _CategoryScenePainter extends CustomPainter {
  const _CategoryScenePainter(this.categoryId, {this.compact = false});

  final String categoryId;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = switch (categoryId) {
      'jus' || 'eau' => const [Color(0xFFD9E8F8), Color(0xFFEFE4F8)],
      'dattes' => const [Color(0xFFE7F3C9), Color(0xFFF6E7A8)],
      'riz' || 'huile' => const [Color(0xFFF3E0D0), Color(0xFFE8C3A8)],
      _ => const [Color(0xFFD6EEF0), Color(0xFFB8DDE0)],
    };
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ).createShader(Offset.zero & size),
    );

    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final s = math.min(size.width, size.height);

    switch (categoryId) {
      case 'jus':
        _glass(
          canvas,
          Offset(cx - s * 0.16, cy),
          s * 0.22,
          const Color(0xFFFF9800),
        );
        _glass(
          canvas,
          Offset(cx + s * 0.18, cy + 4),
          s * 0.2,
          const Color(0xFFE53935),
        );
      case 'eau':
        _bottle(
          canvas,
          Offset(cx - s * 0.14, cy),
          s * 0.18,
          const Color(0xFF4FC3F7),
        );
        _bottle(
          canvas,
          Offset(cx + s * 0.16, cy + 6),
          s * 0.16,
          const Color(0xFF81D4FA),
        );
      case 'dattes':
        _bowl(canvas, Offset(cx, cy + 8), s * 0.42, const Color(0xFF6D4C41));
        canvas.drawCircle(
          Offset(cx - 10, cy - 8),
          s * 0.08,
          Paint()..color = const Color(0xFF5D4037),
        );
        canvas.drawCircle(
          Offset(cx + 12, cy - 4),
          s * 0.07,
          Paint()..color = const Color(0xFF4E342E),
        );
        canvas.drawCircle(
          Offset(cx, cy - 18),
          s * 0.06,
          Paint()..color = const Color(0xFF795548),
        );
      case 'huile':
        _bottle(canvas, Offset(cx, cy), s * 0.22, const Color(0xFFFFC107));
      case 'riz':
        _sack(canvas, Offset(cx, cy), s * 0.42);
      case 'savon':
        _bar(canvas, Offset(cx, cy), s * 0.34, const Color(0xFFF8BBD0));
      case 'lessive':
        _bottle(canvas, Offset(cx, cy), s * 0.24, const Color(0xFF4DB6AC));
      default:
        _sack(canvas, Offset(cx, cy), s * 0.38);
    }
  }

  void _glass(Canvas canvas, Offset c, double h, Color liquid) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: h * 0.55, height: h),
      const Radius.circular(6),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: 0.55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, h * 0.12),
          width: h * 0.42,
          height: h * 0.62,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = liquid,
    );
  }

  void _bottle(Canvas canvas, Offset c, double h, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: h * 0.42, height: h),
        const Radius.circular(10),
      ),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, -h * 0.58),
          width: h * 0.18,
          height: h * 0.22,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      c.translate(-h * 0.08, -h * 0.1),
      h * 0.08,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _sack(Canvas canvas, Offset c, double w) {
    final path = Path()
      ..moveTo(c.dx - w * 0.38, c.dy - w * 0.18)
      ..lineTo(c.dx - w * 0.42, c.dy + w * 0.32)
      ..quadraticBezierTo(
        c.dx,
        c.dy + w * 0.42,
        c.dx + w * 0.42,
        c.dy + w * 0.32,
      )
      ..lineTo(c.dx + w * 0.38, c.dy - w * 0.18)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE8D5A3));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFB08940),
    );
  }

  void _bowl(Canvas canvas, Offset c, double w, Color color) {
    final path = Path()
      ..moveTo(c.dx - w / 2, c.dy - 8)
      ..quadraticBezierTo(c.dx, c.dy + w * 0.38, c.dx + w / 2, c.dy - 8);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  void _bar(Canvas canvas, Offset c, double w, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: w * 0.55),
        const Radius.circular(12),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CategoryScenePainter oldDelegate) =>
      oldDelegate.categoryId != categoryId;
}
