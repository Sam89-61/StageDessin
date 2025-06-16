import 'package:flutter/material.dart';
import '../polygoneFill.dart';
import 'dart:math';

class CirclePlayer extends PolygoneFill {
  CirclePlayer({
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

    final radius = size * 1.6;
    final thickness = size * 0.5;
    final rect = Rect.fromCircle(center: position, radius: radius);

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(rect, pi * 0.1, pi * 0.8, false, paint);
  }

  @override
  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);

    final distance = (click - position).distance;
    return distance <= size;
  }
}
