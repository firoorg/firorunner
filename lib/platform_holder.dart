import 'package:firo_runner/holder.dart';
import 'package:firo_runner/main.dart';
import 'package:firo_runner/moving_object.dart';
import 'package:flame/flame.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';

class PlatformHolder extends Holder {
  late Image l1;
  late Image l2;
  late Image m1;
  late Image m2;
  late Image r1;
  late Image r2;
  late Image o1;
  late Image o2;
  int timeSinceLastTopHole = 0;
  int timeSinceLastBottomHole = 0;

  @override
  Future load() async {
    l1 = await Flame.images.load('platform-left-nowire-frames.png');
    l2 = await Flame.images.load('platform-left-wire-frames.png');
    m1 = await Flame.images.load('platform-mid-nowire-frames.png');
    m2 = await Flame.images.load('platform-mid-wire-frames.png');
    r1 = await Flame.images.load('platform-right-nowire-frames.png');
    r2 = await Flame.images.load('platform-right-wire-frames.png');
    o1 = await Flame.images.load('platform-single-nowire-frames.png');
    o2 = await Flame.images.load('platform-single-wire-frames.png');
  }

  @override
  void setUp() {
    timeSinceLastTopHole = 0;
    timeSinceLastBottomHole = 0;
    super.setUp();
  }

  void removeUnfairObstacles(
      MyGame gameRef, Platform currentPlatform, int from, int to) {
    for (int i = from; i <= to; i++) {
      if (i == 0) {
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
    }
  }

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
      return false;
    }
  }

  double getFlushX() {
    MovingObject platform =
        objects[2].firstWhere((element) => element.sprite.x > 0, orElse: () {
      return objects[5].firstWhere((element) => element.sprite.x > 0,
          orElse: () {
        return objects[8].firstWhere((element) => element.sprite.x > 0);
      });
    });
    return platform.sprite.x;
  }

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
