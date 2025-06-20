import '../polygoneVoid.dart';
import 'package:flutter/material.dart';

class RectangleU extends PolygoneVoid {
  RectangleU({
    required Offset position,
    required double size,
    required Color color,
    required Duration startTime,
  }) : super(
         position: position,
         size: size,
         color: color,
         startTime: startTime,
       );
  @override
  void draw(Canvas canvas, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);

    final paint = Paint();
    final rect = Rect.fromCenter(
      center: position,
      width: size * 4,
      height: size * 2,
    );
    canvas.drawRect(
      rect,
      paint
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);
    final rect = Rect.fromCenter(
      center: position,
      width: size * 4,
      height: size * 2,
    );
    return rect.contains(click);
  }
}
