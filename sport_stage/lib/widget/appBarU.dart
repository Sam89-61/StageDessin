import 'package:flutter/material.dart';
import '../drawingmode.dart';

class AppbarU extends StatelessWidget implements PreferredSizeWidget {
  final bool textMode;
  final DrawingMode selectedMode;
  final VoidCallback onTextModeToggle;
  final Function(DrawingMode) onShapeSelected; // Changer Shape en DrawingMode
  final VoidCallback onReset;
  final VoidCallback? onPausePlayer;
  final VoidCallback? cancelPausePlayer;

  const AppbarU({
    Key? key,
    required this.textMode,
    required this.selectedMode,
    required this.onTextModeToggle,
    required this.onShapeSelected,
    required this.onReset,
    this.onPausePlayer,
    this.cancelPausePlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        TextButton(onPressed: onTextModeToggle, child: Text("Text")),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.circle); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("Cercle"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.line); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("line"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.rectangle); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("rectangle"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.circle_player); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("player_circle"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.spot); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("spot"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.zoom); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("Zoom"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.screen); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("screen"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.arrow_passe); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("arrow_passe"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.arrow_run); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("arrow_run"),
        ),
        TextButton(
          onPressed: () {
            cancelPausePlayer?.call();
            onShapeSelected(DrawingMode.arrow_dribble); // Utiliser DrawingMode
            onPausePlayer?.call();
          },
          child: Text("arrow_dribble"),
        ),
        TextButton(
          onPressed:
              () => onShapeSelected(DrawingMode.mouse), // Utiliser DrawingMode
          child: Text("Mouse"),
        ),
        TextButton(onPressed: onReset, child: Text("Reset")),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
