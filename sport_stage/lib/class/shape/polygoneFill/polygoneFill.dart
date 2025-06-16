import 'package:flutter/material.dart';
import '../shape.dart';

abstract class PolygoneFill extends Shape {
  double size;
  PolygoneFill({
    required Offset position,
    required this.size,
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
