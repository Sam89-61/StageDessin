import 'package:flutter/material.dart';
import 'package:sport_stage/class/calque/calque_manager.dart';
import 'package:sport_stage/drawingmode.dart';
import '../shape/shape.dart';
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
import 'package:sport_stage/class/shape/polygoneFill/element/circle_player.dart';

class DrawingManager {
  final CalquesManager calquesManager;
  DrawingMode selectedMode;
  Duration duree;
  Size videoSize;
  final Function setState;
  final VoidCallback? onPausePlayer;

  int? currentPointIndex;
  bool isDrawing = false;
  List<Offset> screenDirection = [];
  DrawingManager({
    required this.calquesManager,
    required this.selectedMode,
    required this.duree,
    required this.videoSize,
    required this.setState,
    this.onPausePlayer,
  });

  void addpoints(
    TapUpDetails details, {
    required bool textMode,
    required Function putText,
    required double size,
  }) {
    final position = details.localPosition;
    final relativePosition = Shape.getRelativePosition(position, videoSize);
    if (DrawingMode.screen == selectedMode) {
      print(screenDirection.length);
      screenDirection.add(relativePosition);
    }
    final shapeText =
        calquesManager.getAllVisibleShapes(duree).whereType<TextU>().toList();
    for (int i = 0; i < shapeText.length; i++) {
      if (shapeText[i].clickShape(position, videoSize)) {
        // Position absolue pour la détection
        onPausePlayer?.call();
        print("Text clicked: ${shapeText[i]}");
        putText(relativePosition, existingText: shapeText[i], textIndex: i);
        return;
      }
    }
    if (textMode) {
      putText(relativePosition);
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
          size: 5,
          color: Colors.red,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.circle) {
        final newAge = Circle(
          position: relativePosition,
          size: 5,
          color: Colors.red,
          startTime: duree,
        );
        calquesManager.addShape(newAge);
        currentPointIndex = calquesManager.findCalqueByShape(newAge);
      } else if (selectedMode == DrawingMode.rectangle) {
        final newAge = RectangleU(
          position: relativePosition,
          size: 5,
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
      isDrawing = false;
      currentPointIndex = null;
      screenDirection.clear();
    });
  }
}
