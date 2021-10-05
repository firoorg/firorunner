import 'package:firo_runner/holder.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/wire.dart';
import 'package:firo_runner/main.dart';

class WireHolder extends Holder {
  late List<Sprite> wire;

  @override
  Future load() async {
    wire = await loadListSprites("wire", "wire", 12);
  }

  List<Sprite> getWire() {
    return wire;
  }

  bool generateWire(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0}) {
    if (objects[level].isNotEmpty) {
      return false;
    }

    if (random.nextInt(100) > 100) {
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

      objects[level].add(wire);
      gameRef.add(wire.sprite);
      if (platform != null) {
        platform.removeChildren.add(() {
          objects[level].remove(wire);
          wire.remove();
        });
      }
      return false;
    }
  }
}
