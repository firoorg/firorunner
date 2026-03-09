import 'package:firo_runner/biome.dart';
import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/bug.dart';
import 'package:firo_runner/main.dart';

class BugHolder extends Holder {
  late List<Sprite> bug;
  late List<Sprite> breaking;

  @override
  Future load() async {
    bug = await loadListSprites("bug", "bug", 8);
    breaking = await loadListSprites("bug", "bug_break", 13);
  }

  List<Sprite> getBug(String state) {
    switch (state) {
      case "normal":
        return bug;
      default:
        return breaking;
    }
  }

  // Generate a bug on the indicated level if it is possible.
  bool generateBug(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0}) {
    if (objects[level].isNotEmpty) {
      return false;
    }

    // Higher spawn chance in later biomes.
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

  // Returns the spawn threshold percentage based on current biome.
  // Higher value = more likely to spawn.
  int _getSpawnThreshold(MyGame gameRef) {
    switch (gameRef.gameState.currentBiome) {
      case Biome.city:
        return 25;
      case Biome.grassland:
        return 35;
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
