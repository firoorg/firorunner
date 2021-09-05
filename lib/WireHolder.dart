import 'dart:math';

import 'package:firo_runner/Platform.dart';
import 'package:flame/flame.dart';

import 'Wire.dart';
import 'main.dart';

class WireHolder {
  var wire;
  Random random = Random();

  late List<List<Wire>> wires = [];

  Future loadWires() async {
    wire = await Flame.images.load("wire-frames.png");
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
      int nearestPlatform = level <= 0
          ? 0
          : level <= 3
              ? 2
              : level <= 6
                  ? 5
                  : 8;

      Platform? platform =
          gameRef.platformHolder.getPlatformOffScreen(nearestPlatform);
      double xCoordinate = -100;

      if (level == 0) {
        xCoordinate = gameRef.size.x;
      } else if (platform != null) {
        xCoordinate = platform.sprite.x;
      } else {
        return false;
      }

      Wire wire = Wire(gameRef);
      if (level % 3 == 0) {
        wire.sprite.renderFlipY = true;
        wire.setPosition(
            xCoordinate, gameRef.blockSize * level - gameRef.blockSize / 6);
      } else {
        wire.setPosition(
            xCoordinate, gameRef.blockSize * level + gameRef.blockSize / 10);
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

  void removePast(MyGame gameRef) {
    for (List<Wire> wireLevel in wires) {
      for (int i = 0; i < wireLevel.length;) {
        if (wireLevel[i].sprite.x + wireLevel[i].sprite.width < 0) {
          wireLevel[i].sprite.remove();
          wireLevel.removeAt(i);
          continue;
        }
        i++;
      }
    }
  }
}
