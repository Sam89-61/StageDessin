import 'package:flutter/material.dart';
import '../shape.dart';

abstract class Arrow extends Shape {
  Offset? relativeEndPosition;
  double perspective;

  Arrow({
    required Offset startPosition,
    this.relativeEndPosition,
    this.perspective = 0.0,
    required Duration startTime,
    required Color color,
  }) : super(
         startTime: startTime,
         color: color,
         relativePosition: startPosition,
       );

  @override
  void updateEndPosition(Offset newEndPosition) {
    relativeEndPosition = newEndPosition;
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
      return (click - start).distance;
    }

    final param = dot / lenSq;

    Offset closestClick;
    if (param < 0) {
      closestClick = start;
    } else if (param > 1) {
      closestClick = end;
    } else {
      closestClick = Offset(start.dx + param * C, start.dy + param * D);
    }

    return (click - closestClick).distance;
  }

  Offset? getAbsoluteEndPosition(Size videoSize) {
    if (relativeEndPosition == null) return null;
    return Offset(
      relativeEndPosition!.dx * videoSize.width,
      relativeEndPosition!.dy * videoSize.height,
    );
  }
}
