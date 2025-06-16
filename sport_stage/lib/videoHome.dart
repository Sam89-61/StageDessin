import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/scheduler.dart';
import 'package:sport_stage/class/calque/calque_manager.dart';
import 'package:sport_stage/class/shape/arrow/element/arrow_dribble.dart';
import 'package:sport_stage/class/shape/arrow/element/arrow_pass.dart';
import 'package:sport_stage/class/shape/arrow/element/arrow_run.dart';
import 'package:sport_stage/class/shape/figure/element/screen.dart';
import 'package:sport_stage/class/shape/line/element/simple_line.dart';
import 'package:sport_stage/class/shape/polygoneFill/element/spot.dart';
import 'package:sport_stage/class/shape/polygoneFill/element/zoom.dart';
import 'package:sport_stage/class/shape/polygoneVoid/element/circle.dart';
import 'package:sport_stage/class/shape/polygoneVoid/element/rectangle.dart';
import 'package:sport_stage/class/shape/text/textU.dart';
import 'class/shape/polygoneFill/element/circle_player.dart';

import 'widget/appBarU.dart';
import 'class/trackTimeline.dart';
import 'class/clipTimeline.dart';
import 'widget/track_timeline.dart';
import 'class/draw.dart';
import 'class/shape/shape.dart';
import 'drawingmode.dart';
import 'dart:async';

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
  File? file;

  bool textMode = false;
  late CalquesManager calquesManager;

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
  //int? drag_index;

  Size videoSize = Size.zero;

  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
    calquesManager = CalquesManager(calques: []);
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

  Future<void> selectVideo() async {
    final XFile? fileX = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Videos', extensions: ['mp4', 'mov', 'avi']),
      ],
    );

    if (fileX != null) {
      file = File(fileX.path);

      await _player?.dispose();
      setState(() {
        _isInitialized = false;
        calquesManager.clear();
      });
      _player = Player();
      _controller = VideoController(_player!);

      await _player!.open(Media(file!.path));

      setState(() {
        _isInitialized = true;
      });

      await _player!.play();
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
    _player?.dispose();
    super.dispose();
  }

  Size getSizeVideo(Size containerSize) {
    if (!_isInitialized && _controller == null) {
      return Size.zero;
    }
    final height = _player?.state.height?.toDouble() ?? 720;
    final width = _player?.state.width?.toDouble() ?? 1280;
    final ratioVideo = width / height;

    final containerSizeRatio = containerSize.width / containerSize.height;

    if (containerSizeRatio > ratioVideo) {
      return Size(containerSize.width, containerSize.width / ratioVideo);
    } else {
      return Size(containerSize.height * ratioVideo, containerSize.height);
    }
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

            _player?.pause();
            pauseTimer?.cancel();

            pauseTimer = Timer(Duration(seconds: 5), () {
              if (mounted && _player != null) {
                _player!.play();
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

  void addpoints(TapUpDetails details) {
    final position = details.localPosition;

    final relativePosition = Shape.getRelativePosition(position, videoSize);
    if (DrawingMode.screen == selectedMode) {
      print(screenDirection.length);
      screenDirection.add(relativePosition);
    }
    final shapeText =
        calquesManager.getAllVisibleShapes(duree).whereType<TextU>().toList();
    for (int i = 0; i < shapeText.length; i++) {
      if (shapeText[i].clickShape(relativePosition, videoSize)) {
        _player!.pause();

        putText(position, existingText: shapeText[i], textIndex: i);
        return;
      }
    }
    if (textMode) {
      putText(position);
      return;
    }
    setState(() {
      if (DrawingMode.mouse == selectedMode) {
      } else if (DrawingMode.circle_player == selectedMode) {
        calquesManager.addShape(
          CirclePlayer(
            position: relativePosition,
            size: 20,
            color: Colors.green,
            startTime: duree,
          ),
        );
      } else if (DrawingMode.screen == selectedMode &&
          screenDirection.length == 2) {
        calquesManager.addShape(
          Screen(
            startPosition: screenDirection[0],
            endPosition: screenDirection[1],
            size: 80,
            startTime: duree,
            color: Colors.red,
          ),
        );
        screenDirection.clear();
      } else if (DrawingMode.spot == selectedMode) {
        calquesManager.addShape(
          Spot(
            position: relativePosition,
            size: 60,
            color: Colors.white.withOpacity(0.5),
            startTime: duree,
          ),
        );
      } else if (DrawingMode.circle == selectedMode) {
        calquesManager.addShape(
          Circle(
            position: relativePosition,
            size: 40,
            color: Colors.red,
            startTime: duree,
          ),
        );
      } else if (DrawingMode.rectangle == selectedMode) {
        calquesManager.addShape(
          RectangleU(
            position: relativePosition,
            size: 40,
            color: Colors.red,
            startTime: duree,
          ),
        );
      } else if (DrawingMode.screen != selectedMode) {
        screenDirection.clear();
      }
    });
  }

  void startDraw(DragStartDetails details) {
    final position = details.localPosition;
    final relativePosition = Shape.getRelativePosition(position, videoSize);
    setState(() {
      if (selectedMode == DrawingMode.mouse) {
        final allShapes = calquesManager.getAllVisibleShapes(duree);
        for (var i = 0; i < allShapes.length; i++) {
          if (allShapes[i].visibleShape(duree) &&
              allShapes[i].clickShape(relativePosition, videoSize)) {
            setState(() {
              drag = true;
            });
            return;
          }
        }
      }

      isDrawing = true;
      if (selectedMode == DrawingMode.arrow_dribble) {
        final newShape = ArrowDribble(
          startPosition: relativePosition,
          startTime: duree,
          color: Colors.red,
          perspective: 0,
        );
        calquesManager.addShape(newShape);
        currentPointIndex = calquesManager.findCalqueByShape(newShape);
      } else if (selectedMode == DrawingMode.arrow_run) {
        final newAge = ArrowRun(
          startPosition: relativePosition,
          startTime: duree,
          color: Colors.red,
          perspective: 0,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.arrow_passe) {
        final newAge = ArrowPass(
          startPosition: relativePosition,
          startTime: duree,
          color: Colors.red,
          perspective: 0,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.line) {
        final newAge = SimpleLine(
          startPosition: relativePosition,
          width: 2,
          color: Colors.yellow,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.zoom) {
        final newAge = Zoom(
          position: relativePosition,
          size: size,
          color: Colors.red,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.circle) {
        final newAge = Circle(
          position: relativePosition,
          size: size,
          color: Colors.red,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.rectangle) {
        final newAge = RectangleU(
          position: relativePosition,
          size: size,
          color: Colors.red,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      }
    });
  }

  void updateDraw(DragUpdateDetails details) {
    final position = details.localPosition;

    // if (drag == true && drag_index != null) {
    //   shapes[drag_index!].startPosition = relativePosition;
    //   if (shapes[drag_index!].endPosition != null) {
    //     final newEnd =
    //         shapes[drag_index!].endPosition! - shapes[drag_index!].position;
    //     shapes[drag_index!].endPosition = relativePosition + newEnd;
    //   }
    // }
    final relativePosition = Shape.getRelativePosition(position, videoSize);

    if (isDrawing == true && currentPointIndex != null) {
      setState(() {
        if (selectedMode == DrawingMode.arrow_passe ||
            selectedMode == DrawingMode.arrow_run ||
            selectedMode == DrawingMode.arrow_dribble ||
            selectedMode == DrawingMode.line) {
          calquesManager
              .getCalqueIndex(currentPointIndex!)
              .shape!
              .updateEndPosition(relativePosition);
        } else {
          calquesManager
              .getCalqueIndex(currentPointIndex!)
              .shape!
              .updateSize(details.delta.dy);
        }
      });
    }
  }

  void endDraw(DragEndDetails details) {
    setState(() {
      drag = false;

      isDrawing = false;
      currentPointIndex = null;
      screenDirection.clear();
    });
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
          });
        },
        onShapeSelected: (DrawingMode mode) {
          // Maintenant ça correspond
          setState(() {
            textMode = false;
            selectedMode = mode; // mode est de type DrawingMode
          });
        },
        onReset: () {
          setState(() {
            textMode = false;
            selectedMode = DrawingMode.mouse;
            calquesManager.clear();
          });
        },
        onPausePlayer: _player?.pause,
        cancelPausePlayer: cancelPauseTimer,
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          // Intercepter la touche espace
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            // Empêcher le comportement par défaut
            if (_isInitialized && _player != null) {
              if (_player!.state.playing) {
                setState(() {
                  isPaused = true;
                });
                _player!.pause();
              } else {
                setState(() {
                  selectedMode = DrawingMode.mouse;

                  isPaused = false;
                });
                cancelPauseTimer();

                _player!.play();
              }
            }
            return KeyEventResult.handled; // Consommer l'événement
          }
          return KeyEventResult.ignored;
        },
        child: Padding(
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

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isInitialized && _controller != null)
                        Expanded(
                          flex: 5,
                          child: StreamBuilder<Duration>(
                            stream: _player!.stream.position,
                            builder: (context, snapshot) {
                              final currentTime =
                                  snapshot.data ?? Duration.zero;
                              duree = currentTime;
                              pauseShape(currentTime);

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  videoSize = getSizeVideo(constraints.biggest);

                                  return Stack(
                                    children: [
                                      Video(controller: _controller!),
                                      MouseRegion(
                                        cursor: getCursor(),

                                        child: GestureDetector(
                                          onTapUp: addpoints,
                                          onPanStart: startDraw,
                                          onPanUpdate: updateDraw,
                                          onPanEnd: endDraw,
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

                      if (!_isInitialized || _controller == null)
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
                          color: Colors.grey,
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
                                      children: [
                                        Text(
                                          calquesManager
                                              .getCalqueIndex(index)
                                              .getName,
                                        ),
                                        SizedBox(width: 5),

                                        Text(
                                          "${Duration(hours: shape.inHours, minutes: shape.inMinutes % 60, seconds: shape.inSeconds % 60)}",
                                        ),
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
                if (_isInitialized && _player != null)
                  IconButton(
                    onPressed: () {
                      if (_player!.state.playing) {
                        setState(() {
                          isPaused = true;
                        });
                        _player!.pause();
                      } else {
                        setState(() {
                          selectedMode = DrawingMode.mouse;
                          isPaused = false;
                        });
                        setState(() {
                          cancelPauseTimer();
                          print("test");
                        });

                        _player!.play();
                      }
                    },
                    icon: StreamBuilder<bool>(
                      stream: _player!.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? true;
                        return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
                      },
                    ),
                  ),
                if (_isInitialized &&
                    _player !=
                        null) // je suis débile c'est la timeline celui la
                  StreamBuilder<Duration>(
                    stream: _player!.stream.position,
                    builder: (context, snapshot) {
                      final time = snapshot.data ?? Duration.zero;
                      final duration = _player!.state.duration;
                      duree = time;

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

                      final tracks = [
                        trackTimeline(
                          name: "La vidéo",
                          color: Colors.blue,
                          clip: [
                            clipTimeline(
                              name: "Clip principal",
                              start: Duration.zero,
                              duration: duration,
                              color: Colors.blue.shade300,
                            ),
                          ],
                        ),
                      ];

                      return Column(
                        children: [
                          MultiTrackTimeline(
                            totalDuration: duration,
                            currentPosition: time,
                            tracks: tracks,
                            onSeek: (newtime) {
                              _player!.seek(newtime);
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
