import '../arrow.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' show PathMetric;

class ArrowRun extends Arrow {
  ArrowRun({
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
  @override
  void draw(Canvas canvas, Size sizeVideo) {
    final endPosition = getAbsoluteEndPosition(sizeVideo);
    final startPosition = getAbsolutePosition(sizeVideo);

    final paint = Paint();
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

    final linePath = Path();
    linePath.moveTo(startPosition.dx, startPosition.dy);
    linePath.lineTo(lineEnd.dx, lineEnd.dy);

    final dashPath = Path();
    final dashLength = 8.0;
    final gapLength = 8.0;
    double distance = 0;
    bool draw = true;

    for (PathMetric pathMetric in linePath.computeMetrics()) {
      while (distance < pathMetric.length) {
        final nextDistance = distance + (draw ? dashLength : gapLength);
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(
              distance,
              nextDistance.clamp(0, pathMetric.length),
            ),
            Offset.zero,
          );
        }
        distance = nextDistance;
        draw = !draw;
      }
    }
    const shadowOffset = Offset(8, 8);
    final shadowPaint =
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

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
    canvas.drawPath(dashPath.shift(shadowOffset), shadowPaint);

    final dashPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawPath(dashPath, dashPaint);

    final arrowPath =
        Path()
          ..moveTo(endPosition!.dx, endPosition!.dy)
          ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();
    canvas.drawPath(
      arrowPath,
      paint
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final endPosition = getAbsoluteEndPosition(sizeVideo);
    final startPosition = getAbsolutePosition(sizeVideo);
    if (endPosition == null) return false;

    final tolerance = 10.0; // Normaliser la tolérance
    final distance = distanceFromPointToLine(click, startPosition, endPosition);
    return distance <= tolerance;
  }
}
