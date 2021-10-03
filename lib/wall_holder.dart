import 'package:firo_runner/holder.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/wall.dart';
import 'package:firo_runner/main.dart';

class WallHolder extends Holder {
  late Image wall;

  @override
  Future load() async {
    wall = await Flame.images.load("wall-frames.png");
  }

  getWall() {
    return wall;
  }

  bool generateWall(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0}) {
    if (objects[level].length > 1) {
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

      Wall wall = Wall(gameRef);
      wall.setPosition(xCoordinate, gameRef.blockSize * level);
      wall.bottomPlatformLevel = level + 1;

      if (gameRef.isTooNearOtherObstacles(wall.sprite.toRect())) {
        return false;
      }

      objects[level].add(wall);
      gameRef.add(wall.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          objects[level].remove(wall);
          wall.remove();
        });
      }
      return false;
    }
  }
}
