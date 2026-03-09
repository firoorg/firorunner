import 'package:firo_runner/biome.dart';
import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/wire.dart';
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

    // In city biome, wires have 0% base spawn (controlled by dangerLevel in fillScreen).
    // In later biomes, spawn chance increases progressively.
    int spawnThreshold = _getSpawnThreshold(gameRef);
    if (random.nextInt(100) > spawnThreshold) {
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

  // Returns the spawn threshold percentage based on current biome.
  int _getSpawnThreshold(MyGame gameRef) {
    switch (gameRef.gameState.currentBiome) {
      case Biome.city:
        return 100; // Original: always spawns when called (controlled by fillScreen)
      case Biome.grassland:
        return 30;
      case Biome.forest:
        return 40;
      case Biome.desert:
        return 45;
      case Biome.tundra:
        return 50;
      case Biome.utopia:
        return 55;
    }
  }
}
