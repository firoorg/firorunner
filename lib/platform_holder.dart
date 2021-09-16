import 'dart:math';

import 'package:firo_runner/bug.dart';
import 'package:firo_runner/main.dart';
import 'package:firo_runner/wire.dart';
import 'package:flame/flame.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';

class PlatformHolder {
  late Image l1;
  late Image l2;
  late Image m1;
  late Image m2;
  late Image r1;
  late Image r2;
  late Image o1;
  late Image o2;
  late List<List<Platform>> platforms = [];
  int timeSinceLastTopHole = 0;
  int timeSinceLastBottomHole = 0;
  Random random = Random();

  Future loadPlatforms() async {
    l1 = await Flame.images.load('platform-left-nowire-frames.png');
    l2 = await Flame.images.load('platform-left-wire-frames.png');
    m1 = await Flame.images.load('platform-mid-nowire-frames.png');
    m2 = await Flame.images.load('platform-mid-wire-frames.png');
    r1 = await Flame.images.load('platform-right-nowire-frames.png');
    r2 = await Flame.images.load('platform-right-wire-frames.png');
    o1 = await Flame.images.load('platform-single-nowire-frames.png');
    o2 = await Flame.images.load('platform-single-wire-frames.png');
  }

  void setUp() {
    timeSinceLastTopHole = 0;
    timeSinceLastBottomHole = 0;
    for (int i = 0; i < platforms.length; i++) {
      for (int j = 0; j < platforms[i].length; j++) {
        remove(platforms[i], j);
      }
    }
    platforms = [];
    for (int i = 0; i < 9; i++) {
      platforms.add([]);
    }
  }

  void removeUnfairObstacles(
      MyGame gameRef, Platform currentPlatform, int from, int to) {
    for (int i = from; i <= to; i++) {
      if (i == 0) {
        for (Bug bug in gameRef.bugHolder.bugs[0]) {
          if (bug.sprite.x >= currentPlatform.sprite.x &&
              bug.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            gameRef.bugHolder.bugs[0].remove(bug);
            bug.remove();
          }
        }
        for (Wire wire in gameRef.wireHolder.wires[0]) {
          if (wire.sprite.x >= currentPlatform.sprite.x &&
              wire.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            gameRef.wireHolder.wires[0].remove(wire);
            wire.remove();
          }
        }
      } else {
        int nearestPlatform = getNearestPlatform(i);
        for (Platform platform in platforms[nearestPlatform]) {
          if (platform.sprite.x >= currentPlatform.sprite.x &&
              platform.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            platform.remove();
            platform.prohibitObstacles = true;
          }
        }
      }
    }
  }

  int getNearestPlatform(int level) {
    return level <= 0
        ? 0
        : level <= 3
            ? 2
            : level <= 6
                ? 5
                : 8;
  }

  void generatePlatforms(MyGame gameRef) {
    while (!generatePlatform(gameRef, 2)) {
      timeSinceLastTopHole++;
    }
    while (!generatePlatform(gameRef, 5)) {
      timeSinceLastBottomHole++;
    }

    int topChance =
        random.nextInt(timeSinceLastTopHole > 0 ? timeSinceLastTopHole : 1);
    int bottomChance = random
        .nextInt(timeSinceLastBottomHole > 0 ? timeSinceLastBottomHole : 1);

    if (topChance > 50) {
      removeUnfairObstacles(
          gameRef, platforms[2][platforms[2].length - 4], 0, 4);
      // Create an opening in the top.
      remove(platforms[2], platforms[2].length - 2);
      remove(platforms[2], platforms[2].length - 2);

      timeSinceLastTopHole = 0;
    }
    if (bottomChance > 30) {
      Platform start = platforms[5].elementAt(platforms[5].length - 10);
      generatePlatform(gameRef, 8, xPosition: start.sprite.position.x);
      for (int i = 0; i < 8; i++) {
        generatePlatform(gameRef, 8);
      }
      int lastToRemove = platforms[5].length - 3;
      int firstToRemove = platforms[5].length - 10;

      removeUnfairObstacles(gameRef, platforms[5][lastToRemove - 1], 3, 7);
      remove(platforms[5], lastToRemove);
      remove(platforms[5], lastToRemove);

      removeUnfairObstacles(gameRef, platforms[5][firstToRemove - 1], 3, 7);
      remove(platforms[5], firstToRemove);
      remove(platforms[5], firstToRemove);

      timeSinceLastBottomHole = 0;
    }
  }

  bool generatePlatform(MyGame gameRef, int level, {double xPosition = 0}) {
    double xCoordinate = xPosition;
    if (platforms[level].isNotEmpty && xPosition == 0) {
      xCoordinate = platforms[level].last.getRightEnd();
    }

    if (xCoordinate > gameRef.size.x + 2000) {
      return true;
    } else {
      Platform platform = Platform(gameRef);
      platform.setPosition(xCoordinate, gameRef.blockSize * level);
      platform.row = level;
      gameRef.add(platform.sprite);
      platforms[level].add(platform);
      return false;
    }
  }

  void update(double dt) {
    for (List<Platform> platformLevel in platforms) {
      for (Platform p in platformLevel) {
        p.update(dt);
      }
    }
  }

  void remove(List<Platform> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder[j].sprite.remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<Platform> platformLevel in platforms) {
      while (platformLevel.isNotEmpty &&
          platformLevel[0].sprite.position.x + platformLevel[0].sprite.width <
              0) {
        remove(platformLevel, 0);
      }
    }
  }

  double getFlushX() {
    Platform platform =
        platforms[2].firstWhere((element) => element.sprite.x > 0, orElse: () {
      return platforms[5].firstWhere((element) => element.sprite.x > 0,
          orElse: () {
        return platforms[8].firstWhere((element) => element.sprite.x > 0);
      });
    });
    return platform.sprite.x;
  }

  Platform? getPlatformOffScreen(int level) {
    for (int i = 0; i < platforms[level].length; i++) {
      Platform p = platforms[level][i];
      if (p.sprite.x > p.gameRef.size.x) {
        int chosenIndex = random.nextInt(platforms[level].length - i) + i;
        return platforms[level][chosenIndex];
      }
    }
    return null;
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    for (List<Platform> platformLevel in platforms) {
      for (Platform p in platformLevel) {
        p.resize(newSize, xRatio, yRatio);
        p.sprite.y = (p.sprite.position.y / p.gameRef.blockSize).round() *
            p.gameRef.blockSize;
      }
    }
  }
}
