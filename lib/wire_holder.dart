import 'dart:math';

import 'package:firo_runner/platform.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/wire.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';

class WireHolder {
  late Image wire;
  Random random = Random();

  late List<List<Wire>> wires = [];

  Future loadWires() async {
    wire = await Flame.images.load("wire-frames.png");
  }

  void setUp() {
    for (int i = 0; i < wires.length; i++) {
      for (int j = 0; j < wires[i].length; j++) {
        remove(wires[i], j);
      }
    }
    wires = [];
    for (int i = 0; i < 9; i++) {
      wires.add([]);
    }
  }

  getWire() {
    return wire;
  }

  bool generateWire(MyGame gameRef, int level, bool force) {
    if (wires[level].isNotEmpty) {
      return false;
    }

    if (random.nextInt(100) > 100) {
      return true;
    } else {
      int nearestPlatform = gameRef.platformHolder.getNearestPlatform(level);

      Platform? platform =
          gameRef.platformHolder.getPlatformOffScreen(nearestPlatform);
      if (platform != null && platform.prohibitObstacles) {
        return false;
      }
      double xCoordinate = -100;

      if (level == 0) {
        xCoordinate = gameRef.size.x;
      } else if (platform != null) {
        xCoordinate = platform.sprite.x;
      } else {
        return false;
      }

      Wire wire = Wire(gameRef);
      wire.sprite.renderFlipX = true;
      if (level % 3 == 0) {
        wire.sprite.renderFlipY = true;
        wire.setPosition(
            xCoordinate, gameRef.blockSize * level - 2 * gameRef.blockSize / 7);
      } else {
        wire.setPosition(
            xCoordinate, gameRef.blockSize * level + gameRef.blockSize / 10);
      }

      if (gameRef.isTooNearOtherObstacles(wire.sprite.toRect())) {
        return false;
      }

      wires[level].add(wire);
      gameRef.add(wire.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          wires[level].remove(wire);
          wire.remove();
        });
      }
      return false;
    }
  }

  int totalWires() {
    int total = 0;
    for (List<Wire> levelWires in wires) {
      total += levelWires.length;
    }
    return total;
  }

  void update(double dt) {
    for (List<Wire> wireLevel in wires) {
      for (Wire p in wireLevel) {
        p.update(dt);
      }
    }
  }

  void remove(List<Wire> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder[j].sprite.remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<Wire> wireLevel in wires) {
      for (int i = 0; i < wireLevel.length;) {
        if (wireLevel[i].sprite.x + wireLevel[i].sprite.width < 0) {
          remove(wireLevel, i);
          continue;
        }
        i++;
      }
    }
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    for (List<Wire> platformLevel in wires) {
      for (Wire p in platformLevel) {
        p.resize(newSize, xRatio, yRatio);
      }
    }
  }
}
