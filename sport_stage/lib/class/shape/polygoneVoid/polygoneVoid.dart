import 'package:flutter/material.dart';
import '../shape.dart';

abstract class PolygoneVoid extends Shape {
  double size;
  PolygoneVoid({
    required Offset position,
    this.size = 20,
    required Color color,
    required Duration startTime,
  }) : super(startTime: startTime, color: color, relativePosition: position);

  @override
  void updateSize(double direction) {
    if (direction > 0) {
      size = (size + 0.5).clamp(1.0, 150);
    } else if (direction < 0) {
      size = (size - 0.5).clamp(1.0, 150);
    }
  }
}
