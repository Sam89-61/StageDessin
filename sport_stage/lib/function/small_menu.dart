import 'package:flutter/material.dart';
import 'package:sport_stage/class/calque/calque_manager.dart';

Future<void> smallMenu(
  BuildContext context,
  CalquesManager calquesManager,
  VoidCallback onDelete, {
  int? shapeIndex,
}) async {
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
                    onDelete();
                    Navigator.of(context).pop();
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
