import 'package:flutter/material.dart';
import '../theme.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Colors.white});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.ocean.withValues(alpha: .15)),
          boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: child,
      );
}

class OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const OptionTile({super.key, required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? C.mist : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? C.ocean : C.ocean.withValues(alpha: .2), width: selected ? 2 : 1),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: C.ink.withValues(alpha: .75))),
                ]),
              ),
              Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? C.ocean : C.ink.withValues(alpha: .3)),
            ]),
          ),
        ),
      );
}

class TagPill extends StatelessWidget {
  final String text;
  final Color color;
  const TagPill(this.text, {super.key, this.color = C.butter});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      );
}

class StarRow extends StatelessWidget {
  final int filled;
  final double size;
  const StarRow(this.filled, {super.key, this.size = 18});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            5,
            (i) => Icon(i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size, color: i < filled ? const Color(0xFFE0A526) : C.ink.withValues(alpha: .3))),
      );
}

class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const StateMessage({super.key, required this.icon, required this.title, required this.body, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: C.butter, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: C.ocean),
            ),
            const SizedBox(height: 16),
            Text(title, style: hand(30), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15.5, height: 1.4)),
            if (actionLabel != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ]),
        ),
      );
}

class CoastPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint();
    p.color = C.mist;
    canvas.drawRect(Offset.zero & s, p);
    p.color = C.butter;
    canvas.drawCircle(Offset(s.width * .78, s.height * .3), s.height * .13, p);
    p.color = C.sage;
    final hill = Path()
      ..moveTo(0, s.height * .62)
      ..quadraticBezierTo(s.width * .2, s.height * .42, s.width * .45, s.height * .62)
      ..lineTo(0, s.height * .7)
      ..close();
    canvas.drawPath(hill, p);
    final lx = s.width * .2, base = s.height * .6;
    p.color = C.cream;
    canvas.drawPath(
        Path()
          ..moveTo(lx - 16, base)
          ..lineTo(lx - 9, base - 78)
          ..lineTo(lx + 9, base - 78)
          ..lineTo(lx + 16, base)
          ..close(),
        p);
    p.color = C.peach;
    canvas.drawRect(Rect.fromLTWH(lx - 12.5, base - 52, 25, 12), p);
    canvas.drawRect(Rect.fromLTWH(lx - 10, base - 78, 20, 8), p);
    p.color = C.ocean;
    canvas.drawRect(Rect.fromLTWH(lx - 8, base - 92, 16, 14), p);
    p.color = C.seaGlass;
    final sea = Path()..moveTo(0, s.height * .72);
    for (double x = 0; x <= s.width; x += 40) {
      sea.quadraticBezierTo(x + 10, s.height * .68, x + 20, s.height * .72);
      sea.quadraticBezierTo(x + 30, s.height * .76, x + 40, s.height * .72);
    }
    sea
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(sea, p);
    p.color = C.ocean.withValues(alpha: .55);
    final deep = Path()..moveTo(0, s.height * .88);
    for (double x = 0; x <= s.width; x += 50) {
      deep.quadraticBezierTo(x + 12, s.height * .84, x + 25, s.height * .88);
      deep.quadraticBezierTo(x + 38, s.height * .92, x + 50, s.height * .88);
    }
    deep
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(deep, p);
    p.color = C.peach;
    final bx = s.width * .62, by = s.height * .74;
    canvas.drawPath(
        Path()
          ..moveTo(bx, by)
          ..lineTo(bx + 46, by)
          ..lineTo(bx + 38, by + 12)
          ..lineTo(bx + 8, by + 12)
          ..close(),
        p);
    p.color = C.cream;
    canvas.drawPath(
        Path()
          ..moveTo(bx + 22, by - 2)
          ..lineTo(bx + 22, by - 30)
          ..lineTo(bx + 40, by - 2)
          ..close(),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Shows a distance nicely: under 1 km in metres, otherwise in km.
String fmtDist(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
}