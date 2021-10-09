import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/wall.dart';
import 'package:firo_runner/main.dart';

class WallHolder extends Holder {
  late List<Sprite> wall;

  @override
  Future load() async {
    wall = await loadListSprites("wall", "wall", 5);
  }

  List<Sprite> getWall() {
    return wall;
  }

  bool generateWall(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0}) {
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
