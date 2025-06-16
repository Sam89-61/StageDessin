import 'package:flutter/material.dart';
import 'trackTimeline.dart';

class TrackPainter extends CustomPainter {
  final trackTimeline track;
  final Duration totalDuration;

  TrackPainter({required this.track, required this.totalDuration});

  @override
  void paint(Canvas canvas, Size size) {
    for (final clip in track.clip) {
      final startX =
          (clip.start.inMilliseconds / totalDuration.inMilliseconds) *
          size.width;
      final width =
          (clip.duration.inMilliseconds / totalDuration.inMilliseconds) *
          size.width;

      print("startX: $startX, width: $width"); // Debug

      // Clip qui prend toute la hauteur disponible
      final rect = Rect.fromLTWH(startX, 0, width, size.height);
      final paint =
          Paint()
            ..color = clip.color
            ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(0)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
