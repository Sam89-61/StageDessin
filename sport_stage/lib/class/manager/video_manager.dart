import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';

class VideoPlayerManager {
  Player? _player;
  VideoController? _controller;
  bool _isInitialized = false;
  File? currentFile;
  Size videoSize = Size.zero;

  // Getters
  Player? get getPlayer => _player;
  VideoController? get getController => _controller;
  bool get getIsInitialized => _isInitialized;
  File? get getCurrentFile => currentFile;
  Size get getVideoSize => videoSize;

  // Streams
  Stream<Duration>? get positionStream => _player?.stream.position;
  Stream<bool>? get playingStream => _player?.stream.playing;
  Duration get duration => _player?.state.duration ?? Duration.zero;
  bool get isPlaying => _player?.state.playing ?? false;

  VideoPlayerManager() {
    MediaKit.ensureInitialized();
  }

  Future<void> selectVideo() async {
    final XFile? fileX = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Videos', extensions: ['mp4', 'mov', 'avi']),
      ],
    );

    if (fileX != null) {
      await _loadVideo(File(fileX.path));
    }
  }

  Future<void> _loadVideo(File file) async {
    await _player?.dispose();

    currentFile = file;
    _isInitialized = false;
    videoSize = Size.zero;

    _player = Player();
    _controller = VideoController(_player!);

    try {
      await _player!.open(Media(file.path));
      _isInitialized = true;
      await _player!.play();
    } catch (e) {
      print('Erreur lors du chargement de la vidéo: $e');
      _isInitialized = false;
    }
  }

  Size calculateVideoSize(Size containerSize) {
    if (!_isInitialized || _controller == null) {
      return Size.zero;
    }

    final height = _player?.state.height?.toDouble() ?? 720;
    final width = _player?.state.width?.toDouble() ?? 1280;
    final ratioVideo = width / height;

    final containerSizeRatio = containerSize.width / containerSize.height;

    Size calculatedSize;
    if (containerSizeRatio > ratioVideo) {
      calculatedSize = Size(
        containerSize.width,
        containerSize.width / ratioVideo,
      );
    } else {
      calculatedSize = Size(
        containerSize.height * ratioVideo,
        containerSize.height,
      );
    }

    videoSize = calculatedSize;
    return calculatedSize;
  }

  Future<void> play() async {
    await _player?.play();
  }

  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player?.seek(position);
  }

  @override
  void dispose() {
    _player?.dispose();
  }
}
