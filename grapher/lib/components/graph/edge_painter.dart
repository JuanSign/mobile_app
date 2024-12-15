import 'package:flutter/material.dart';

class EdgePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double pct;
  final Color firstPart;
  final Color secondPart;
  final Paint defaultPaint;
  final Paint secondaryPaint;

  EdgePainter({
    required this.start,
    required this.end,
    this.pct = 100,
    this.firstPart = Colors.black,
    this.secondPart = Colors.black,
  })  : defaultPaint = Paint()
          ..color = firstPart
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke,
        secondaryPaint = Paint()
          ..color = secondPart
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset midPoint = Offset(
      (start.dx + (end.dx - start.dx) * (pct / 100)),
      (start.dy + (end.dy - start.dy) * (pct / 100)),
    );
    canvas.drawLine(start, midPoint, defaultPaint);
    if (pct != 100) canvas.drawLine(midPoint, end, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
