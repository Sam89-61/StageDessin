import '../polygoneFill.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Spot extends PolygoneFill {
  Spot({
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
          ..color = color.withOpacity(0.50)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    final start = position;
    final end = Offset(position.dx, 0);

    final spotWidth = size;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);

    final perpX = -dy / length * spotWidth / 2;
    final perpY = dx / length * spotWidth / 2;

    final p1 = Offset(start.dx + perpX, start.dy + perpY);
    final p2 = Offset(start.dx - perpX, start.dy - perpY);
    final p3 = Offset(end.dx - perpX, end.dy - perpY);
    final p4 = Offset(end.dx + perpX, end.dy + perpY);

    final spotPath =
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();

    canvas.drawPath(spotPath, paint);
  }

  @override
  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);
    final start = position;
    final end = Offset(position.dx, 0);

    final spotWidth = size;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);

    final perpX = -dy / length * spotWidth / 2;
    final perpY = dx / length * spotWidth / 2;

    final p1 = Offset(start.dx + perpX, start.dy + perpY);
    final p2 = Offset(start.dx - perpX, start.dy - perpY);
    final p3 = Offset(end.dx - perpX, end.dy - perpY);
    final p4 = Offset(end.dx + perpX, end.dy + perpY);

    final spotPath =
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();
    return spotPath.contains(click);
  }
}
