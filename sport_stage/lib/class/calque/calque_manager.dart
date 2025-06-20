import '../shape/shape.dart';

import 'calque.dart';
import 'package:flutter/material.dart';

class CalquesManager {
  List<Calque> calques;
  int calqueIndexActive;
  CalquesManager({required this.calques, this.calqueIndexActive = 0});

  List<Calque> get getCalques {
    return calques;
  }

  int get getcalqueIndexActive {
    return calqueIndexActive;
  }

  Calque get activeCalque {
    return calques[calqueIndexActive];
  }

  Calque getCalqueIndex(int index) {
    return calques[index];
  }

  Calque createEmptyCalque(String name) {
    final newCalque = Calque(name: name);
    calques.add(newCalque);
    calqueIndexActive = calques.length - 1;
    return newCalque;
  }

  Calque createShapeCalque(Shape shape, String name) {
    final newCalque = Calque(name: name, shape: shape);
    calques.add(newCalque);
    calqueIndexActive = calques.length - 1;
    return newCalque;
  }

  void removeCalque(int index) {
    calques.removeAt(index);
  }

  void setActiveCalque(int index) {
    calqueIndexActive = index;
  }

  void addShape(Shape shape, {String? name}) {
    if (name == null) {
      name = generateLayerName(shape);
    }
    createShapeCalque(shape, name);
  }

  void cleanEmptyCalques() {
    for (var i = 0; i < calques.length; i++) {
      if (calques[i].isEmpty) {
        calques.removeAt(i);
      }
    }
  }

  void clear() {
    calques.clear();
  }

  String generateLayerName(Shape shape) {
    int nb = 0;
    final Type type = shape.runtimeType;
    for (var i = 0; i < calques.length; i++) {
      if (calques[i].shape.runtimeType == type) {
        nb += 1;
      }
    }
    if (nb == 0) {
      nb = 1;
      return "${type}_$nb";
    }
    nb += 1;
    return "${type}_$nb";
  }

  List<Shape> getAllVisibleShapes(Duration currentTime) {
    List<Shape> visibleShape = [];
    for (var calque in calques) {
      final shape = calque.getVisibleShape(currentTime);
      if (shape != null) {
        visibleShape.add(shape);
      }
    }
    return visibleShape;
  }

  int? findCalqueByShape(Shape shape) {
    for (var i = 0; i < calques.length; i++) {
      if (shape == calques[i].shape) {
        return i;
      }
    }
    return null;
  }

  void moveCalque(int oldIndex, int newIndex) {
    if (oldIndex >= calques.length ||
        newIndex >= calques.length ||
        oldIndex < 0 ||
        newIndex < 0) {
      return;
    }

    final old = calques[oldIndex];
    calques.removeAt(oldIndex);
    calques.insert(newIndex, old);
    if (calqueIndexActive == oldIndex) {
      calqueIndexActive = newIndex;
    }
  }
}
