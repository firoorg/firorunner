import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/main.dart';
import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:flame/components.dart';
import 'package:firo_runner/moving_objects/platform.dart';

class PlatformHolder extends Holder {
  late List<Sprite> l1;
  late List<Sprite> l2;
  late List<Sprite> m1;
  late List<Sprite> m2;
  late List<Sprite> r1;
  late List<Sprite> r2;
  late List<Sprite> o1;
  late List<Sprite> o2;
  bool noTopObstaclesForNext = false;
  bool noMiddleObstaclesForNext = false;
  int timeSinceLastTopHole = 0;
  int timeSinceLastBottomHole = 0;

  @override
  Future load() async {
    l1 = await loadListSprites("platform", "platform-left-nowire-frames", 5);
    l2 = await loadListSprites("platform", "platform-left-wire-frames", 5);
    m1 = await loadListSprites("platform", "platform-mid-nowire-frames", 5);
    m2 = await loadListSprites("platform", "platform-mid-wire-frames", 5);
    r1 = await loadListSprites("platform", "platform-right-nowire-frames", 5);
    r2 = await loadListSprites("platform", "platform-right-wire-frames", 5);
    o1 = await loadListSprites("platform", "platform-single-nowire-frames", 5);
    o2 = await loadListSprites("platform", "platform-single-wire-frames", 5);
  }

  @override
  void setUp() {
    timeSinceLastTopHole = 0;
    timeSinceLastBottomHole = 0;
    super.setUp();
  }

  // Removes obstacles from around openings in the floor so that the game is
  // not unfair to the player.
  void removeUnfairObstacles(
      MyGame gameRef, Platform currentPlatform, int from, int to) {
    for (int i = from; i <= to; i++) {
      if (i == 0) {
        // First level has a harder difficulty curve, and no platforms are on
        // level -1, so objects have to be removed differently.
        List<MovingObject> bugLevel = gameRef.bugHolder.objects[0];
        for (MovingObject bug in gameRef.bugHolder.objects[0]) {
          if (bug.sprite.x >= currentPlatform.sprite.x &&
              bug.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            gameRef.bugHolder.remove(bugLevel, bugLevel.indexOf(bug));
          }
        }
        List<MovingObject> wireLevel = gameRef.wireHolder.objects[0];
        for (MovingObject wire in gameRef.wireHolder.objects[0]) {
          if (wire.sprite.x >= currentPlatform.sprite.x &&
              wire.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            gameRef.wireHolder.remove(wireLevel, wireLevel.indexOf(wire));
          }
        }
      } else {
        // All other objects on the other levels can be removed simply.
        int nearestPlatform = getNearestPlatform(i);
        for (MovingObject platform in objects[nearestPlatform]) {
          if (platform.sprite.x >= currentPlatform.sprite.x &&
              platform.sprite.x <
                  currentPlatform.sprite.x + 4 * currentPlatform.sprite.width) {
            (platform as Platform).removeChildrenObjects();
            platform.prohibitObstacles = true;
          }
        }
      }
    }
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
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
          gameRef, objects[2][objects[2].length - 4] as Platform, 0, 4);
      // Create an opening in the top.
      remove(objects[2], objects[2].length - 2);
      remove(objects[2], objects[2].length - 2);

      timeSinceLastTopHole = 0;
      noTopObstaclesForNext = true;
    }
    if (bottomChance > 30) {
      Platform start = objects[5].elementAt(objects[5].length - 10) as Platform;
      generatePlatform(gameRef, 8, xPosition: start.sprite.position.x);
      for (int i = 0; i < 8; i++) {
        generatePlatform(gameRef, 8);
      }
      int lastToRemove = objects[5].length - 3;
      int firstToRemove = objects[5].length - 10;

      removeUnfairObstacles(
          gameRef, objects[5][lastToRemove - 1] as Platform, 3, 7);
      remove(objects[5], lastToRemove);
      remove(objects[5], lastToRemove);

      removeUnfairObstacles(
          gameRef, objects[5][firstToRemove - 1] as Platform, 3, 7);
      remove(objects[5], firstToRemove);
      remove(objects[5], firstToRemove);

      timeSinceLastBottomHole = 0;
      noMiddleObstaclesForNext = true;
    }
  }

  // Create a platform object.
  bool generatePlatform(MyGame gameRef, int level, {double xPosition = 0}) {
    double xCoordinate = xPosition;
    if (objects[level].isNotEmpty && xPosition == 0) {
      xCoordinate = objects[level].last.getRightEnd();
    }

    if (xCoordinate > gameRef.size.x + 2000) {
      return true;
    } else {
      Platform platform = Platform(gameRef);
      platform.setPosition(xCoordinate, gameRef.blockSize * level);
      platform.row = level;
      gameRef.add(platform.sprite);
      objects[level].add(platform);
      if (level == 2 && noTopObstaclesForNext) {
        platform.prohibitObstacles = true;
        noTopObstaclesForNext = false;
      } else if (level == 5 && noMiddleObstaclesForNext) {
        platform.prohibitObstacles = true;
        noMiddleObstaclesForNext = false;
      }
      return false;
    }
  }

  // Choose a random platform that is off screen from the player.
  Platform? getPlatformOffScreen(int level) {
    for (int i = 0; i < objects[level].length; i++) {
      Platform p = objects[level][i] as Platform;
      if (p.sprite.x > p.gameRef.size.x) {
        int chosenIndex = random.nextInt(objects[level].length - i) + i;
        return objects[level][chosenIndex] as Platform;
      }
    }
    return null;
  }
}
