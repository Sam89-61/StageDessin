import '../arrow.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ArrowDribble extends Arrow {
  ArrowDribble({
    required Offset startPosition,
    Offset? endPosition,
    required Duration startTime,
    required Color color,
    required double perspective,
  }) : super(
         startPosition: startPosition,
         relativeEndPosition: endPosition,
         startTime: startTime,
         color: color,
         perspective: perspective,
       );
  @override
  void draw(Canvas canvas, Size videoSize) {
    final endPosition = getAbsoluteEndPosition(videoSize);
    final startPosition = getAbsolutePosition(videoSize);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final angle = atan2(
      endPosition!.dy - startPosition.dy,
      endPosition.dx - startPosition.dx,
    );
    final arrowLength = 25;
    final lineEndOffset = 22.0;

    final lineEnd = Offset(
      endPosition.dx - lineEndOffset * cos(angle),
      endPosition.dy - lineEndOffset * sin(angle),
    );
    final segments = 10;
    final amplitude = 25;
    final dx = (endPosition.dx - startPosition.dx) / segments;
    final dy = (endPosition.dy - startPosition.dy) / segments;
    final zigzagPath = Path();
    zigzagPath.moveTo(startPosition.dx, startPosition.dy);
    for (int j = 1; j <= segments; j++) {
      final x = startPosition.dx + dx * j;
      final y =
          startPosition.dy + dy * j + (j % 2 == 0 ? -amplitude : amplitude);
      if (j == segments) {
        zigzagPath.lineTo(lineEnd.dx, lineEnd.dy);
      } else {
        zigzagPath.lineTo(x, y);
      }
    }

    const shadowOffset = Offset(8, 8);
    final shadowPaint =
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

    canvas.drawPath(zigzagPath.shift(shadowOffset), shadowPaint);

    final arrowPoint1 = Offset(
      endPosition.dx - arrowLength * cos(angle - pi / 6),
      endPosition.dy - arrowLength * sin(angle - pi / 6),
    );
    final arrowPoint2 = Offset(
      endPosition.dx - arrowLength * cos(angle + pi / 6),
      endPosition.dy - arrowLength * sin(angle + pi / 6),
    );
    final arrowPathShadow =
        Path()
          ..moveTo(
            endPosition.dx + shadowOffset.dx,
            endPosition.dy + shadowOffset.dy,
          )
          ..lineTo(
            arrowPoint1.dx + shadowOffset.dx,
            arrowPoint1.dy + shadowOffset.dy,
          )
          ..lineTo(
            arrowPoint2.dx + shadowOffset.dx,
            arrowPoint2.dy + shadowOffset.dy,
          )
          ..close();
    canvas.drawPath(arrowPathShadow, shadowPaint);

    canvas.drawPath(
      zigzagPath,
      paint
        ..color = color
        ..strokeWidth = 4,
    );

    final arrowPath =
        Path()
          ..moveTo(endPosition.dx, endPosition.dy)
          ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();
    canvas.drawPath(arrowPath, paint..color = color);
  }

  @override
  bool clickShape(Offset click, Size videoSize) {
    final endPosition = getAbsoluteEndPosition(videoSize);
    final position = getAbsolutePosition(videoSize);
    if (endPosition == null) return false;

    final tolerance = 10; // Normaliser la tolérance
    final distance = distanceFromPointToLine(click, position, endPosition);
    return distance <= tolerance;
  }
}
