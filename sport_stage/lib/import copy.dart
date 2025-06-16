import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class videoImport extends StatefulWidget {
  const videoImport({super.key});

  @override
  State<videoImport> createState() => _videoImportState();
}

class _videoImportState extends State<videoImport> {
  Player? _player;
  VideoController? _controller;
  bool _isInitialized = false;
  String time = "";
  double? _seekTo;
  File? file;

  @override
  void initState() {
    super.initState();
    // Initialiser MediaKit
    MediaKit.ensureInitialized();
  }

  Future<void> selectVideo() async {
    final XFile? fileX = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Videos', extensions: ['mp4', 'mov', 'avi']),
      ],
    );

    if (fileX != null) {
      file = File(fileX.path);

      await _player?.dispose();

      _player = Player();
      _controller = VideoController(_player!);

      await _player!.open(Media(file!.path));

      setState(() {
        _isInitialized = true;
      });

      await _player!.play();
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  selectVideo();
                },
                child: const Text("Importer"),
              ),
              const SizedBox(height: 20),
              if (_isInitialized && _controller != null)
                Expanded(child: Video(controller: _controller!)),
              if (_isInitialized && _player != null)
                IconButton(
                  onPressed: () {
                    _player!.playOrPause();
                  },
                  icon: StreamBuilder<bool>(
                    stream: _player!.stream.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? true;
                      return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
                    },
                  ),
                ),
              if (_isInitialized && _player != null)
                StreamBuilder<Duration>(
                  stream: _player!.stream.position,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _player!.state.duration;
                    String time(Duration d) {
                      final minutes = d.inMinutes
                          .remainder(60)
                          .toString()
                          .padLeft(2, '0');
                      final seconds = d.inSeconds
                          .remainder(60)
                          .toString()
                          .padLeft(2, '0');

                      return "$minutes:$seconds";
                    }

                    return Column(
                      children: [
                        Slider(
                          value: _seekTo ?? position.inMilliseconds.toDouble(),
                          min: 0,
                          max: duration.inMilliseconds.toDouble().clamp(
                            1,
                            double.infinity,
                          ),
                          onChanged: (value) async {
                            setState(() {
                              _seekTo = value;
                            });
                          },
                          onChangeEnd: (value) async {
                            setState(() {
                              _player!.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(time(position)),
                            Text(time(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
