import '../polygoneVoid.dart';
import 'package:flutter/material.dart';

class Circle extends PolygoneVoid {
  Circle({
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

    canvas.drawCircle(
      position,
      size,
      paint
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);
    final distance = (click - position).distance;
    return distance <= size;
  }
}
