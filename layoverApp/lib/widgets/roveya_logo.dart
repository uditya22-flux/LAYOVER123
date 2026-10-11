import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class RoveyaLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const RoveyaLogo({
    super.key,
    this.size = 140,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final markSize = size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF296775), Color(0xFF153F48)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: C.ocean.withValues(alpha: 0.28),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: C.butter.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border.all(
              color: C.butter.withValues(alpha: 0.4),
              width: 2.5,
            ),
          ),
          child: CustomPaint(
            size: Size(markSize, markSize),
            painter: const _RoveyaLogoPainter(),
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 20),
          Text(
            'Roveya',
            style: hand(38, color: C.ocean),
          ),
          const SizedBox(height: 2),
          Text(
            'FIND THE 5-STAR IN 1-STAR SPOTS',
            style: GoogleFonts.nunito(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: C.ink.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoveyaLogoPainter extends CustomPainter {
  const _RoveyaLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final paint = Paint()..isAntiAlias = true;

    // 1. Concentric compass rings
    paint
      ..style = PaintingStyle.stroke
      ..color = C.butter.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), r * 0.82, paint);

    paint
      ..color = C.butter.withValues(alpha: 0.2)
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cy), r * 0.70, paint);

    // 2. Compass ticks (12 hour / dial ticks)
    paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final isCardinal = i % 3 == 0;
      final tickStart = r * (isCardinal ? 0.70 : 0.74);
      final tickEnd = r * 0.82;

      paint
        ..color = isCardinal
            ? C.butter.withValues(alpha: 0.85)
            : C.butter.withValues(alpha: 0.4)
        ..strokeWidth = isCardinal ? 2.0 : 1.0;

      final p1 = Offset(cx + tickStart * math.cos(angle), cy + tickStart * math.sin(angle));
      final p2 = Offset(cx + tickEnd * math.cos(angle), cy + tickEnd * math.sin(angle));
      canvas.drawLine(p1, p2, paint);
    }

    // 3. North beacon marker (diamond notch at 12 o'clock)
    final northDiamond = Path()
      ..moveTo(cx, cy - r * 0.84)
      ..lineTo(cx - 3.5, cy - r * 0.77)
      ..lineTo(cx, cy - r * 0.70)
      ..lineTo(cx + 3.5, cy - r * 0.77)
      ..close();
    paint
      ..style = PaintingStyle.fill
      ..color = C.peach;
    canvas.drawPath(northDiamond, paint);

    // 4. Secondary compass points (diagonal, shorter, faceted)
    final diagLength = r * 0.42;
    final diagIn = r * 0.12;
    final diagAngles = [math.pi / 4, 3 * math.pi / 4, 5 * math.pi / 4, 7 * math.pi / 4];

    for (final a in diagAngles) {
      final tip = Offset(cx + diagLength * math.cos(a), cy + diagLength * math.sin(a));
      final leftBase = Offset(cx + diagIn * math.cos(a - math.pi / 4), cy + diagIn * math.sin(a - math.pi / 4));
      final rightBase = Offset(cx + diagIn * math.cos(a + math.pi / 4), cy + diagIn * math.sin(a + math.pi / 4));

      paint.style = PaintingStyle.fill;
      // Left facet
      paint.color = C.seaGlass.withValues(alpha: 0.6);
      final pLeft = Path()
        ..moveTo(cx, cy)
        ..lineTo(leftBase.dx, leftBase.dy)
        ..lineTo(tip.dx, tip.dy)
        ..close();
      canvas.drawPath(pLeft, paint);

      // Right facet
      paint.color = C.butter.withValues(alpha: 0.45);
      final pRight = Path()
        ..moveTo(cx, cy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(rightBase.dx, rightBase.dy)
        ..close();
      canvas.drawPath(pRight, paint);
    }

    // 5. Cardinal compass needles (East, South, West)
    final cardLength = r * 0.54;
    final cardIn = r * 0.14;

    // East (0 rad)
    _drawNeedle(canvas, cx, cy, 0, cardLength, cardIn, C.seaGlass, C.butter.withValues(alpha: 0.7));
    // South (pi/2 rad)
    _drawNeedle(canvas, cx, cy, math.pi / 2, cardLength, cardIn, C.seaGlass, C.butter.withValues(alpha: 0.7));
    // West (pi rad)
    _drawNeedle(canvas, cx, cy, math.pi, cardLength, cardIn, C.seaGlass, C.butter.withValues(alpha: 0.7));

    // 6. North needle (Elongated, prominent hero needle in Peach & Butter)
    final northLength = r * 0.65;
    _drawNeedle(canvas, cx, cy, -math.pi / 2, northLength, cardIn * 1.1, C.peach, C.butter);

    // 7. Center Star (Verified 5-Star standout emblem)
    _drawStar(canvas, Offset(cx, cy), 5, r * 0.20, r * 0.085, C.cream);

    // Center pin / jewel
    paint
      ..style = PaintingStyle.fill
      ..color = C.peach;
    canvas.drawCircle(Offset(cx, cy), r * 0.05, paint);

    paint
      ..style = PaintingStyle.fill
      ..color = C.butter;
    canvas.drawCircle(Offset(cx, cy), r * 0.025, paint);
  }

  void _drawNeedle(
    Canvas canvas,
    double cx,
    double cy,
    double angle,
    double length,
    double baseWidth,
    Color leftColor,
    Color rightColor,
  ) {
    final tip = Offset(cx + length * math.cos(angle), cy + length * math.sin(angle));
    final perpAngle = angle + math.pi / 2;
    final leftSide = Offset(cx + baseWidth * math.cos(perpAngle), cy + baseWidth * math.sin(perpAngle));
    final rightSide = Offset(cx - baseWidth * math.cos(perpAngle), cy - baseWidth * math.sin(perpAngle));

    final paint = Paint()..style = PaintingStyle.fill..isAntiAlias = true;

    // Left facet
    paint.color = leftColor;
    final pLeft = Path()
      ..moveTo(cx, cy)
      ..lineTo(leftSide.dx, leftSide.dy)
      ..lineTo(tip.dx, tip.dy)
      ..close();
    canvas.drawPath(pLeft, paint);

    // Right facet
    paint.color = rightColor;
    final pRight = Path()
      ..moveTo(cx, cy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(rightSide.dx, rightSide.dy)
      ..close();
    canvas.drawPath(pRight, paint);
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerRadius, double innerRadius, Color color) {
    final path = Path();
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final rad = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + rad * math.cos(angle);
      final y = center.dy + rad * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();

    // Subtle drop glow
    final glow = Paint()
      ..color = C.butter.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glow);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

