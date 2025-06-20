import 'package:flutter/material.dart';
import '../shape/shape.dart';

class Calque {
  String name;
  Shape? shape;
  bool isLocked = false;
  Color color;

  Calque({
    required this.name,
    this.shape,
    this.isLocked = false,
    this.color = const Color.fromARGB(122, 0, 0, 0),
  });

  void setShape(Shape newShape) {
    if (!isLocked) {
      shape = newShape;
    }
  }

  void removeShape() {
    if (!isLocked) {
      shape = null;
    }
  }

  String get getName {
    return name;
  }

  bool hasVisibleShape(Duration currentTime) {
    if (shape == null) {
      return false;
    }
    return shape!.visibleShape(currentTime);
  }

  Shape? getVisibleShape(Duration currentTime) {
    if (shape != null && shape!.visibleShape(currentTime)) {
      return shape;
    }
    return null;
  }

  Calque duplicate() {
    return Calque(name: name, shape: shape, isLocked: isLocked, color: color);
  }

  bool get isEmpty {
    return shape == null;
  }
}
