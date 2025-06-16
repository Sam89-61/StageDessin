import 'package:flutter/material.dart';

class timeRulerPainter extends CustomPainter {
  final Duration totalDuration;
  final Duration currentPosition;

  timeRulerPainter({
    required this.totalDuration,
    required this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final draw =
        Paint()
          ..color = const Color.fromARGB(23, 0, 0, 0)
          ..strokeWidth = 1;

    // Ligne de base
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      draw,
    );

    final interval = (totalDuration.inSeconds / 10).ceil();

    // Marqueurs intermédiaires
    for (var i = 0; i <= totalDuration.inSeconds; i += interval) {
      final pos = (i / totalDuration.inSeconds) * size.width;
      canvas.drawLine(
        Offset(pos, size.height - 10),
        Offset(pos, size.height - 1),
        draw,
      );

      final timeText = "${(i ~/ 60)}:${(i % 60).toString().padLeft(2, '0')}";
      final textPainter = TextPainter(
        text: TextSpan(
          text: timeText,
          style: const TextStyle(color: Colors.black, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos - textPainter.width / 2, 0));
    }

    _drawEndTime(canvas, size);

    final currentX =
        (currentPosition.inMilliseconds / totalDuration.inMilliseconds) *
        size.width;
    final cursorPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      cursorPaint,
    );
  }

  void _drawEndTime(Canvas canvas, Size size) {
    final endX = size.width;

    final endPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(endX, size.height - 15),
      Offset(endX, size.height),
      endPaint,
    );

    final totalMinutes = totalDuration.inMinutes;
    final totalSeconds = totalDuration.inSeconds.remainder(60);
    final endTimeText =
        "${totalMinutes}:${totalSeconds.toString().padLeft(2, '0')}";

    final endTextPainter = TextPainter(
      text: TextSpan(
        text: endTimeText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    endTextPainter.layout();

    endTextPainter.paint(canvas, Offset(endX - endTextPainter.width, 0));
  }

  @override
  bool shouldRepaint(timeRulerPainter oldDelegate) =>
      oldDelegate.currentPosition != currentPosition ||
      oldDelegate.totalDuration != totalDuration;
}
