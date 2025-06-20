import '../figure.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Screen extends Figure {
  Screen({
    required Offset startPosition,
    required Offset endPosition,
    required double size,
    required Color color,
    required Duration startTime,
  }) : super(
         startPosition: startPosition,
         relativeEndPosition: endPosition,
         size: size,
         color: color,
         startTime: startTime,
       );

  void draw(Canvas canvas, Size videoSize) {
    final endPosition = getAbsoluteEndPosition(videoSize);
    final startPosition = getAbsolutePosition(videoSize);
    if (endPosition == null) return;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    const shadowOffset = Offset(4, 4);
    final shadowPaint =
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
    canvas.drawLine(startPosition, endPosition, paint..strokeWidth = 4);
    canvas.drawLine(
      startPosition + shadowOffset,
      endPosition + shadowOffset,
      shadowPaint,
    );

    final angle = atan2(
      endPosition.dy - startPosition.dy,
      endPosition.dx - startPosition.dx,
    );

    final dx = cos(angle + pi / 2) * size / 2;
    final dy = sin(angle + pi / 2) * size / 2;
    final horizontalStart = Offset(
      startPosition.dx - dx,
      startPosition.dy - dy,
    );
    final horizontalEnd = Offset(startPosition.dx + dx, startPosition.dy + dy);
    canvas.drawLine(horizontalStart, horizontalEnd, paint..strokeWidth = 4);
    canvas.drawLine(
      horizontalStart + shadowOffset,
      horizontalEnd + shadowOffset,
      shadowPaint,
    );
  }

  @override
  bool clickShape(Offset click, videoSize) {
    final endPosition = getAbsoluteEndPosition(videoSize);
    final startPosition = getAbsolutePosition(videoSize);
    if (endPosition == null) return false;
    // Tolérance basée sur l'épaisseur de ligne (4 pixels + marge)
    final tolerance = 6.0;

    // Vérifier le clic sur la ligne principale (verticale)
    final distanceToMainLine = distanceFromPointToLine(
      click,
      startPosition,
      endPosition,
    );
    if (distanceToMainLine <= tolerance) {
      return true;
    }

    // Calculer les points de la ligne horizontale (même calcul que draw())
    final angle = atan2(
      endPosition.dy - startPosition.dy,
      endPosition.dx - startPosition.dx,
    );

    final dx = cos(angle + pi / 2) * size / 2;
    final dy = sin(angle + pi / 2) * size / 2;
    final horizontalStart = Offset(
      startPosition.dx - dx,
      startPosition.dy - dy,
    );
    final horizontalEnd = Offset(startPosition.dx + dx, startPosition.dy + dy);

    // Vérifier le clic sur la ligne horizontale
    final distanceToHorizontalLine = distanceFromPointToLine(
      click,
      horizontalStart,
      horizontalEnd,
    );
    return distanceToHorizontalLine <= tolerance;
  }
}
