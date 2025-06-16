import 'package:flutter/material.dart';
import '../shape.dart';
import 'dart:math';

abstract class Line extends Shape {
  Offset? relativeEndPosition;
  double width;
  Line({
    required Offset startPosition,
    this.relativeEndPosition,
    this.width = 2.0,
    required Color color,
    required Duration startTime,
  }) : super(
         color: color,
         startTime: startTime,
         relativePosition: startPosition,
       );
  @override
  void updateEndPosition(Offset newEndPosition) {
    relativeEndPosition = newEndPosition;
  }

  Offset? getAbsoluteEndPosition(Size videoSize) {
    if (relativeEndPosition == null) return null;
    return Offset(
      relativeEndPosition!.dx * videoSize.width,
      relativeEndPosition!.dy * videoSize.height,
    );
  }

  @override
  double distanceFromPointToLine(Offset click, Offset start, Offset end) {
    final A = click.dx - start.dx;
    final B = click.dy - start.dy;
    final C = end.dx - start.dx;
    final D = end.dy - start.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      // Si la ligne est un point
      return sqrt(A * A + B * B);
    }

    final param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = start.dx;
      yy = start.dy;
    } else if (param > 1) {
      xx = end.dx;
      yy = end.dy;
    } else {
      xx = start.dx + param * C;
      yy = start.dy + param * D;
    }

    final dx = click.dx - xx;
    final dy = click.dy - yy;
    return sqrt(dx * dx + dy * dy);
  }
}
