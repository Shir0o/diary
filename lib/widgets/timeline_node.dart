import 'package:flutter/material.dart';

class TimelineNode extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color color;

  const TimelineNode({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    this.color = const Color(0xFF6751a4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: CustomPaint(
        painter: _TimelinePainter(
          isFirst: isFirst,
          isLast: isLast,
          color: color,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Color color;

  _TimelinePainter({
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    // Draw line
    if (!isFirst) {
      canvas.drawLine(Offset(center, 0), Offset(center, 20), paint);
    }
    if (!isLast) {
      canvas.drawLine(Offset(center, 20), Offset(center, size.height), paint);
    }

    // Draw circle
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center, 20), 6, circlePaint);

    // Draw white inner circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, 20), 3, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
