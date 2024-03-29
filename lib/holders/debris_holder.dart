import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/moving_objects/debris.dart';
import 'package:firo_runner/main.dart';

class DebrisHolder extends Holder {
  late List<Sprite> debris;

  @override
  Future load() async {
    debris = await loadListSprites("debris", "debris", 21);
  }

  List<Sprite> getDebris() {
    return debris;
  }

  bool generateDebris(MyGame gameRef, int level,
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

      Debris debris = Debris(gameRef);
      debris.setPosition(
          xCoordinate, gameRef.blockSize * level - gameRef.blockSize / 3);

      if (gameRef.isTooNearOtherObstacles(debris.sprite.toRect())) {
        return false;
      }

      objects[level].add(debris);
      gameRef.add(debris.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          objects[level].remove(debris);
          debris.remove();
        });
      }
      return false;
    }
  }
}
