import 'package:flutter/material.dart';
import 'package:sport_stage/class/calque/calque_manager.dart';
import 'package:sport_stage/class/shape/shape.dart';
import 'package:sport_stage/class/shape/text/textU.dart';

 Future<void> putText(
    BuildContext context,
    CalquesManager calquesManager,
    void Function(TextU) onAdd,
    void Function(TextU,int) onUpdate,
    VoidCallback onDelete,
    Duration duree,

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
                        onDelete();
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

                        if (existingText != null && textIndex != null) {
                          onUpdate(newText,textIndex);
                          
                        } else {
                          onAdd(newText);
                        }
                    

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
