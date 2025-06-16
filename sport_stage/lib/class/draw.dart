import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sport_stage/class/shape/shape.dart';
import 'dart:math';

class Draw extends CustomPainter {
  List<Shape> shapes;
  Size videoSize;

  Draw({required this.shapes, required this.videoSize});

  void paint(Canvas canvas, Size size) {
    for (var shape in shapes) {
      shape.draw(canvas, videoSize);
      print("object");
    }
  }

  @override
  bool shouldRepaint(Draw oldDelegate) {
    return oldDelegate.shapes != shapes || oldDelegate.videoSize != videoSize;
  }
}
