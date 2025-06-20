import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/scheduler.dart';
import 'package:sport_stage/class/calque/calque_manager.dart';

import 'package:sport_stage/class/timeline/timelineU.dart';
import 'widget/appBarU.dart';
import "class/manager/drawing_manager.dart";
import 'package:sport_stage/class/shape/text/textU.dart';
import 'class/draw/draw.dart';
import 'class/shape/shape.dart';
import 'drawingmode.dart';
import 'dart:async';
import 'package:sport_stage/class/manager/video_manager.dart';

class videoHome extends StatefulWidget {
  const videoHome({super.key});

  @override
  State<videoHome> createState() => _videoHomeState();
}

class _videoHomeState extends State<videoHome> {
  late VideoPlayerManager _videoManager;

  String time = "";
  File? file;
  TimelineU timeline = TimelineU(
    current: Duration.zero,
    start: Duration.zero,
    end: Duration.zero,
  );
  bool textMode = false;
  late CalquesManager calquesManager;
  late DrawingManager drawingManager;
  double TimeV = 1;
  DrawingMode selectedMode = DrawingMode.mouse;
  Duration duree = Duration(seconds: 0);
  int? currentPointIndex;
  bool isDrawing = false;
  double size = 5;
  List<Offset> screenDirection = [];
  Duration? lastseconde;
  bool isPaused = false;
  Timer? pauseTimer;
  bool drag = false;

  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
    _videoManager = VideoPlayerManager();
    calquesManager = CalquesManager(calques: []);
    drawingManager = DrawingManager(
      calquesManager: calquesManager,
      selectedMode: selectedMode,
      duree: duree,
      videoSize: _videoManager.videoSize,
      setState: setState,
      onPausePlayer: _videoManager.pause,
    );
  }

  Future<void> putText(
    Offset position, {
    Shape? existingText,
    int? textIndex,
  }) async {
    String inputText = existingText?.contentText() ?? "";
    double fontSize = existingText?.giveFontSize() ?? 20.0;

    Color textColor = existingText?.color ?? Colors.black;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setTextState) {
            return AlertDialog(
              title: Text("Text"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: inputText),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Entre un text",
                      border: OutlineInputBorder(),
                    ),

                    onChanged: (value) {
                      inputText = value;
                    },
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Text("Taille ${fontSize.toStringAsFixed(2)}"),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 8,
                          max: 72,
                          onChanged: (value) {
                            setTextState(() {
                              fontSize = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    children:
                        [
                              Colors.black,
                              Colors.red,
                              Colors.white,
                              Colors.yellow,
                              Colors.green,
                              Colors.purple,
                            ]
                            .map(
                              (c) => GestureDetector(
                                onTap: () {
                                  setTextState(() {
                                    textColor = c;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border:
                                        textColor == c
                                            ? Border.all(
                                              color: const Color.fromARGB(
                                                255,
                                                182,
                                                182,
                                                182,
                                              ),
                                              width: 1.5,
                                            )
                                            : Border.all(
                                              color: Colors.black,
                                              width: 0.5,
                                            ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              actions: [
                if (existingText != null)
                  TextButton(
                    onPressed: () {
                      if (textIndex != null) {
                        setState(() {
                          calquesManager.removeCalque(textIndex);
                        });
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text("Sypprimer"),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Annuler"),
                ),
                TextButton(
                  onPressed: () {
                    if (inputText.isNotEmpty) {
                      final newText = TextU(
                        position: position,
                        content: inputText,
                        fontSize: fontSize,
                        color: textColor,
                        startTime: duree,
                      );

                      setState(() {
                        if (existingText != null && textIndex != null) {
                          calquesManager.getCalqueIndex(textIndex!).shape =
                              newText;
                        } else {
                          calquesManager.addShape(newText);
                        }
                      });

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(existingText != null ? "Modifier" : "Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  SystemMouseCursor getCursor() {
    if (textMode) {
      return SystemMouseCursors.text;
    }
    switch (selectedMode) {
      case DrawingMode.mouse:
        return SystemMouseCursors.basic;
      case DrawingMode.circle:
        return SystemMouseCursors.click;
      case DrawingMode.rectangle:
        return SystemMouseCursors.click;

      case DrawingMode.circle_player:
        return SystemMouseCursors.click;

      case DrawingMode.spot:
        return SystemMouseCursors.click;

      case DrawingMode.zoom:
        return SystemMouseCursors.zoomOut;
      case DrawingMode.arrow_passe:
        return SystemMouseCursors.precise;
      case DrawingMode.arrow_run:
        return SystemMouseCursors.precise;
      case DrawingMode.arrow_dribble:
        return SystemMouseCursors.precise;
      case DrawingMode.line:
        return SystemMouseCursors.precise;
      case DrawingMode.screen:
        return SystemMouseCursors.precise;
      default:
        return SystemMouseCursors.basic;
    }
  }

  Future<void> smallMenu({int? shapeIndex}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setMenuState) {
            return AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (shapeIndex != null) {
                          calquesManager.removeCalque(shapeIndex);
                          Navigator.of(context).pop();
                        }
                      });
                    },
                    child: Text("sup"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    pauseTimer?.cancel();
    _videoManager.dispose();
    super.dispose();
  }

  void pauseShape(time) {
    if (isPaused || lastseconde == null) {
      lastseconde = time;
      return;
    }
    final allShapes = calquesManager.getAllVisibleShapes(duree);
    for (final shape in allShapes) {
      if (shape.startPause(time, lastseconde!)) {
        // Reporter l'exécution après la construction du widget avec SchedulerBinding
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // mounted est une propriété booléenne héritée de la classe State dans Flutter qui indique si le widget est toujours monté (attaché) dans l'arbre des widgets
            setState(() {
              isPaused = true;
            });

            _videoManager.pause();
            pauseTimer?.cancel();

            pauseTimer = Timer(Duration(seconds: 5), () {
              if (mounted && _videoManager != null) {
                _videoManager.play();
                setState(() {
                  isPaused = false;
                });
                pauseTimer = null;
              }
            });
          }
        });
        break;
      }
    }

    lastseconde = time;
  }

  void cancelPauseTimer() {
    pauseTimer?.cancel();
    pauseTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarU(
        textMode: textMode,
        selectedMode: selectedMode,
        onTextModeToggle: () {
          setState(() {
            textMode = true;
            selectedMode = DrawingMode.mouse;
            _videoManager.pause();
            cancelPauseTimer();
          });
        },
        onShapeSelected: (DrawingMode mode) {
          setState(() {
            textMode = false;
            selectedMode = mode;
          });
        },
        onReset: () {
          setState(() {
            textMode = false;
            selectedMode = DrawingMode.mouse;
            calquesManager.clear();
          });
        },
        onPausePlayer: _videoManager.pause,
        cancelPausePlayer: cancelPauseTimer,
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            if (_videoManager.getIsInitialized) {
              _videoManager.togglePlayPause().then((_) {
                setState(() {
                  isPaused = !_videoManager.isPlaying;
                  if (!isPaused) {
                    selectedMode = DrawingMode.mouse;
                    cancelPauseTimer();
                  }
                });
              });
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _videoManager.selectVideo();
                    if (_videoManager.getIsInitialized) {
                      setState(() {
                        calquesManager.clear();
                      });
                    }
                  },
                  child: const Text("Importer"),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_videoManager.getIsInitialized &&
                          _videoManager.getController != null)
                        Expanded(
                          flex: 5,
                          child: StreamBuilder<Duration>(
                            stream: _videoManager.positionStream,
                            builder: (context, snapshot) {
                              final currentTime =
                                  snapshot.data ?? Duration.zero;
                              duree = currentTime;
                              pauseShape(currentTime);

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final videoSize = _videoManager
                                      .calculateVideoSize(constraints.biggest);
                                  drawingManager.selectedMode = selectedMode;
                                  drawingManager.videoSize = videoSize;
                                  drawingManager.duree = duree;

                                  return Stack(
                                    children: [
                                      Video(
                                        controller:
                                            _videoManager.getController!,
                                      ),
                                      MouseRegion(
                                        cursor: getCursor(),
                                        child: GestureDetector(
                                          onTapUp:
                                              (details) =>
                                                  drawingManager.addpoints(
                                                    details,
                                                    textMode: textMode,
                                                    putText: putText,
                                                    size: size,
                                                  ),
                                          onPanStart: drawingManager.startDraw,
                                          onPanUpdate:
                                              drawingManager.updateDraw,
                                          onPanEnd: drawingManager.endDraw,
                                          onSecondaryTapDown: (
                                            TapDownDetails details,
                                          ) {
                                            final allShapes = calquesManager
                                                .getAllVisibleShapes(duree);
                                            for (
                                              var i = 0;
                                              i < allShapes.length;
                                              i++
                                            ) {
                                              if (allShapes[i].clickShape(
                                                details.localPosition,
                                                videoSize,
                                              )) {
                                                smallMenu(shapeIndex: i);
                                                break;
                                              }
                                            }
                                          },
                                          child: ClipRect(
                                            child: CustomPaint(
                                              painter: Draw(
                                                shapes: calquesManager
                                                    .getAllVisibleShapes(
                                                      currentTime,
                                                    ),
                                                videoSize: videoSize,
                                              ),
                                              child: Container(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),

                      if (!_videoManager.getIsInitialized)
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: Colors.black,
                            child: Center(
                              child: Text(
                                "Aucune vidéo importée",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Center(child: Text("Calque")),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: calquesManager.calques.length,
                                  itemBuilder: (context, index) {
                                    final shape =
                                        calquesManager
                                            .getCalqueIndex(index)
                                            .shape!
                                            .startTime;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 5),
                                        Text(
                                          calquesManager
                                              .getCalqueIndex(index)
                                              .getName,
                                        ),
                                        SizedBox(width: 5),

                                        Text(
                                          "${shape.inHours.toString().padLeft(2, '0')}:"
                                          "${(shape.inMinutes % 60).toString().padLeft(2, '0')}:"
                                          "${(shape.inSeconds % 60).toString().padLeft(2, '0')}:"
                                          "${((shape.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0')}",
                                        ),

                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              calquesManager.removeCalque(
                                                index,
                                              );
                                            });
                                          },
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_videoManager.getIsInitialized &&
                    _videoManager.getPlayer != null)
                  IconButton(
                    onPressed: () {
                      if (_videoManager.getPlayer!.state.playing) {
                        setState(() {
                          isPaused = true;
                        });
                        _videoManager.getPlayer!.pause();
                      } else {
                        setState(() {
                          selectedMode = DrawingMode.mouse;
                          isPaused = false;
                        });
                        setState(() {
                          cancelPauseTimer();
                          print("test");
                        });

                        _videoManager.getPlayer!.play();
                      }
                    },
                    icon: StreamBuilder<bool>(
                      stream: _videoManager.getPlayer!.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? true;
                        return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
                      },
                    ),
                  ),
                if (_videoManager.getIsInitialized &&
                    _videoManager.getPlayer !=
                        null) // je suis débile c'est la timeline celui la
                  StreamBuilder<Duration>(
                    stream: _videoManager.getPlayer!.stream.position,
                    builder: (context, snapshot) {
                      final time = snapshot.data ?? Duration.zero;
                      final duration = _videoManager.getPlayer!.state.duration;
                      duree = time;
                      timeline.current = duree;
                      timeline.start = Duration.zero;
                      timeline.end = duration;
                      if (duration.inMilliseconds <= 0) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Chargement"),
                        );
                      }
                      String StringTime(Duration d) {
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: timeline.current.inMilliseconds.toDouble(),
                            max: timeline.end.inMilliseconds.toDouble(),
                            min: timeline.start.inMilliseconds.toDouble(),
                            onChanged: (newValue) {
                              duree = Duration(milliseconds: newValue.toInt());
                              print("essaie");
                              _videoManager.getPlayer?.seek(duree);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(StringTime(time)),
                              Text(StringTime(duration)),
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
      ),
    );
  }
}
