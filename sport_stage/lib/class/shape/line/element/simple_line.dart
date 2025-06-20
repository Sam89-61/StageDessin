import '../line.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SimpleLine extends Line {
  SimpleLine({
    required Offset startPosition,
    Offset? endPosition,
    required double width,
    required Color color,
    required Duration startTime,
  }) : super(
         startPosition: startPosition,
         relativeEndPosition: endPosition,
         width: width,
         color: color,
         startTime: startTime,
       );
  @override
  void draw(Canvas canvas, Size sizeVideo) {
    final endPosition = getAbsoluteEndPosition(sizeVideo);
    final startPosition = getAbsolutePosition(sizeVideo);
    if (endPosition == null) {
      return;
    }
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;

    final shadowPaint =
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
    final shadowOffset = Offset(8, 8);
    canvas.drawLine(startPosition, endPosition!, paint);
    canvas.drawLine(
      startPosition + shadowOffset,
      endPosition! + shadowOffset,
      shadowPaint,
    );
  }

  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final endPosition = getAbsoluteEndPosition(sizeVideo);
    final position = getAbsolutePosition(sizeVideo);

    if (endPosition == null) return false;

    // Calculer la distance du point de clic à la ligne
    final distance = distanceFromPointToLine(click, position, endPosition);

    // La tolérance doit tenir compte de la largeur de la ligne
    final tolerance = max(width / 2, 5.0); // Au minimum 5 pixels de tolérance

    return distance <= tolerance;
  }
}
