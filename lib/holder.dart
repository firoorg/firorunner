import 'dart:math';

import 'package:firo_runner/moving_object.dart';

import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';

class Holder {
  Random random = Random();

  late List<List<MovingObject>> objects = [];

  Future load() async {}

  void setUp() {
    for (int i = 0; i < objects.length; i++) {
      for (int j = 0; j < objects[i].length; j++) {
        remove(objects[i], j);
      }
    }
    objects = [];
    for (int i = 0; i < 9; i++) {
      objects.add([]);
    }
  }

  int total() {
    int total = 0;
    for (List<MovingObject> levelObjects in objects) {
      total += levelObjects.length;
    }
    return total;
  }

  void update(double dt) {
    for (List<MovingObject> objectLevel in objects) {
      for (MovingObject p in objectLevel) {
        p.update(dt);
      }
    }
  }

  void remove(List<MovingObject> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<MovingObject> objectLevel in objects) {
      for (int i = 0; i < objectLevel.length;) {
        if (objectLevel[i].sprite.x + objectLevel[i].sprite.width < 0) {
          remove(objectLevel, i);
          continue;
        }
        i++;
      }
    }
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    for (List<MovingObject> platformLevel in objects) {
      for (MovingObject p in platformLevel) {
        p.resize(newSize, xRatio, yRatio);
      }
    }
  }
}
