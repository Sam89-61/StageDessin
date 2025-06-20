
import 'package:flutter/material.dart';
class TimelineU {
  Duration current;
  Duration start;
  Duration end;
  TimelineU({
    required this.current,
    required this.start,
    required this.end,
  });

  Duration get currentTime {
    return current;
  } 
}