import 'package:flutter/material.dart';

class trackTimeline {
  final String name;
  final List clip;
  final Color color;

  trackTimeline({
    required this.name,
    required this.clip,
    this.color = Colors.blueAccent,
  });
}
