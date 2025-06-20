import 'package:flutter/material.dart';

class clipTimeline {
  final String name;
  final Duration start;
  final Duration duration;
  final Color color;
  clipTimeline({
    required this.name,
    required this.start,
    required this.duration,
    this.color = Colors.blueAccent,
  });
}
