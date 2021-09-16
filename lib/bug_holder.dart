import 'package:firo_runner/holder.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/bug.dart';
import 'package:firo_runner/main.dart';

class BugHolder extends Holder {
  late Image bug;
  late Image breaking;

  @override
  Future load() async {
    bug = await Flame.images.load("bug-frames.png");
    breaking = await Flame.images.load("bug-break-frames.png");
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
    if (objects[level].isNotEmpty) {
      return false;
    }

    if (random.nextInt(100) > 25) {
      return true;
    } else {
      int nearestPlatform = getNearestPlatform(level);

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

      objects[level].add(bug);
      gameRef.add(bug.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          objects[level].remove(bug);
          bug.remove();
        });
      }
      return false;
    }
  }
}
