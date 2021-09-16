import 'dart:math';

import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/bug.dart';
import 'package:firo_runner/main.dart';

class BugHolder {
  late Image bug;
  late Image breaking;
  Random random = Random();

  late List<List<Bug>> bugs = [];

  Future loadBugs() async {
    bug = await Flame.images.load("bug-frames.png");
    breaking = await Flame.images.load("bug-break-frames.png");
  }

  void setUp() {
    for (int i = 0; i < bugs.length; i++) {
      for (int j = 0; j < bugs[i].length; j++) {
        remove(bugs[i], j);
      }
    }
    bugs = [];
    for (int i = 0; i < 9; i++) {
      bugs.add([]);
    }
  }

  getBug(String state) {
    switch (state) {
      case "normal":
        return bug;
      default:
        return breaking;
    }
  }

  bool generateBug(MyGame gameRef, int level, bool force) {
    if (bugs[level].isNotEmpty) {
      return false;
    }

    if (random.nextInt(100) > 25) {
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

      Bug bug = Bug(gameRef);
      bug.setPosition(xCoordinate, gameRef.blockSize * level);

      if (gameRef.isTooNearOtherObstacles(bug.sprite.toRect())) {
        return false;
      }

      bugs[level].add(bug);
      gameRef.add(bug.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          bugs[level].remove(bug);
          bug.remove();
        });
      }
      return false;
    }
  }

  int totalBugs() {
    int total = 0;
    for (List<Bug> levelBugs in bugs) {
      total += levelBugs.length;
    }
    return total;
  }

  void update(double dt) {
    for (List<Bug> bugLevel in bugs) {
      for (Bug p in bugLevel) {
        p.update(dt);
      }
    }
  }

  void remove(List<Bug> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder[j].sprite.remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<Bug> bugLevel in bugs) {
      for (int i = 0; i < bugLevel.length;) {
        if (bugLevel[i].sprite.x + bugLevel[i].sprite.width < 0) {
          remove(bugLevel, i);
          continue;
        }
        i++;
      }
    }
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    for (List<Bug> platformLevel in bugs) {
      for (Bug p in platformLevel) {
        p.resize(newSize, xRatio, yRatio);
        p.sprite.y = (p.sprite.position.y / p.gameRef.blockSize).round() *
            p.gameRef.blockSize;
      }
    }
  }
}
