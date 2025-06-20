import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class Shape {
  Color color;
  Duration startTime;
  int timePause;
  Offset relativePosition;

  Shape({
    this.color = Colors.red,
    this.timePause = 0,
    required this.startTime,
    required this.relativePosition,
  });

  void draw(Canvas canvas, Size sizeVideo);
  bool clickShape(Offset click, Size sizeVideo);

  bool visibleShape(Duration time) {
    return startTime == time;
  }

  bool startPause(Duration currentTime, Duration lastSeconde) {
    return currentTime >= startTime && lastSeconde < startTime;
  }

  Offset get startPosition => relativePosition;
  set startPosition(Offset value) => relativePosition = value;

  Offset get position => relativePosition;
  set position(Offset value) => relativePosition = value;

  void updateEndPosition(Offset endPosition) {}

  void updateSize(double direction) {}

  String? contentText() {
    return null;
  }

  double? giveFontSize() {
    return null;
  }

  Size? getSize() {
    return null;
  }

  bool click(Offset clickShape, Size sizeVideo) {
    return false;
  }

  double? distanceFromPointToLine(Offset click, Offset start, Offset end) {
    return null;
  }

  Offset getAbsolutePosition(Size sizeVideo) {
    return Offset(
      relativePosition.dx * sizeVideo.width,
      relativePosition.dy * sizeVideo.height,
    );
  }

  void calculTime(){

  }

  static Offset getRelativePosition(Offset absolutePosition, Size sizeVideo) {
    if (sizeVideo.width == 0 || sizeVideo.height == 0) {
      return Offset(0, 0);
    }

    return Offset(
      absolutePosition.dx / sizeVideo.width,
      absolutePosition.dy / sizeVideo.height,
    );
  }
}
