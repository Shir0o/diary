import 'package:flutter/material.dart';

class TimelineNode extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color? color;

  const TimelineNode({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nodeColor = colorScheme.primary;

    return SizedBox(
      width: 40,
      child: CustomPaint(
        painter: _TimelinePainter(
          isFirst: isFirst,
          isLast: isLast,
          color: color ?? nodeColor,
          lineColor: colorScheme.outline.withValues(alpha: 0.3),
          innerCircleColor: colorScheme.surface,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Color color;
  final Color lineColor;
  final Color innerCircleColor;

  _TimelinePainter({
    required this.isFirst,
    required this.isLast,
    required this.color,
    required this.lineColor,
    required this.innerCircleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final paint = Paint()
      ..color = lineColor
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

    // Draw inner circle
    final innerPaint = Paint()
      ..color = innerCircleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, 20), 3, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
