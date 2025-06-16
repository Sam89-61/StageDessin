import 'package:sport_stage/class/shape/polygoneFill/polygoneFill.dart';
import 'package:flutter/material.dart';

class Zoom extends PolygoneFill {
  Zoom({
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
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0;

    final rect = Rect.fromCenter(
      center: position,
      width: size * 4,
      height: size * 2,
    );

    canvas.drawRect(rect, paint);
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
