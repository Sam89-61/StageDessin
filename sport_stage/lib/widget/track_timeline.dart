import 'package:flutter/material.dart';
import '../class/trackTimeline.dart';
import '../class/timeRulerPainter.dart';
import '../class/trackPainter.dart';

class MultiTrackTimeline extends StatefulWidget {
  final Duration totalDuration;
  final Duration currentPosition;
  final List<trackTimeline> tracks;
  final Function? onSeek;
  MultiTrackTimeline({
    super.key,
    required this.totalDuration,
    required this.currentPosition,
    required this.tracks,
    required this.onSeek,
  });

  @override
  State<MultiTrackTimeline> createState() => _MultiTrackTimelineState();
}

class _MultiTrackTimelineState extends State<MultiTrackTimeline> {
  double timeHeight = 40;
  double trackHeight = 80;
  Widget _buildTimeRuler() {
    return Container(
      height: timeHeight,
      child: CustomPaint(
        painter: timeRulerPainter(
          totalDuration: widget.totalDuration,
          currentPosition: widget.currentPosition,
        ),
        child: GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = details.localPosition;
            final progress = localPosition.dx / box.size.width;
            final newPosition = Duration(
              milliseconds:
                  (widget.totalDuration.inMilliseconds * progress).round(),
            );
            widget.onSeek?.call(newPosition);
          },
        ),
      ),
    );
  }

  Widget _buildTrack(trackTimeline track) {
    return Container(
      height: trackHeight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.all(8.0),
            color: track.color.withOpacity(0.1),
            child: Text(
              track.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              height: trackHeight - 45, //
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: CustomPaint(
                size: Size.infinite,
                painter: TrackPainter(
                  track: track,
                  totalDuration: widget.totalDuration,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: timeHeight + widget.tracks.length * trackHeight,
      child: Column(
        children: [
          _buildTimeRuler(),
          ...widget.tracks.map((track) => _buildTrack(track)),
        ],
      ),
    );
  }
}
