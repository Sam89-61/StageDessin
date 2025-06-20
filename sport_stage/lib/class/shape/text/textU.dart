import 'package:flutter/material.dart';
import '../shape.dart';

class TextU extends Shape {
  String content;
  double fontSize;
  TextU({
    required this.content,
    required Offset position,
    required this.fontSize,
    required Color color,
    required Duration startTime,
  }) : super(startTime: startTime, color: color, relativePosition: position);
  @override
  void draw(Canvas canvas, Size videoSize) {
    final position = getAbsolutePosition(videoSize);
    final textPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  String contentText() {
    return content;
  }

  @override
  TextStyle get textStyle => TextStyle(color: color, fontSize: fontSize);

  Size getTextSize() {
    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return Size(textPainter.width, textPainter.height);
  }

  @override
  bool clickShape(Offset click, Size sizeVideo) {
    final position = getAbsolutePosition(sizeVideo);
    final size = getTextSize();
    final rectText = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    return rectText.contains(click);
  }
}
