import 'dart:math';

import 'package:firo_runner/main.dart';
import 'package:flame/flame.dart';
import 'Platform.dart';

class PlatformHolder {
  var platform1;
  var platform2;
  var platform3;
  late List<List<Platform>> platforms = [];
  Random random = Random();

  Future loadPlatforms() async {
    platform1 = await Flame.images.load('p1-frames.png');
    platform2 = await Flame.images.load('p2-frames.png');
    platform3 = await Flame.images.load('p3-frames.png');
    for (int i = 0; i < 9; i++) {
      platforms.add([]);
    }
  }

  getPlatform(int imageNumber) {
    switch (imageNumber) {
      case 1:
        return platform1;
      case 2:
        return platform2;
      default:
        return platform3;
    }
  }

  bool generatePlatform(MyGame gameRef, int level, bool force) {
    double xCoordinate = 0;
    if (platforms[level].isNotEmpty) {
      xCoordinate = platforms[level].last.getRightEnd();
    }

    if (xCoordinate > gameRef.size.x + 1000) {
      return true;
    } else {
      Platform platform = Platform(gameRef);
      platform.setPosition(xCoordinate, gameRef.blockSize * level);
      gameRef.add(platform.sprite);
      platforms[level].add(platform);
      return false;
    }
  }

  void update(double dt) {
    for (List<Platform> platformLevel in platforms) {
      for (Platform p in platformLevel) {
        p.update(dt);
      }
    }
  }

  void removePast(MyGame gameRef) {
    for (List<Platform> platformLevel in platforms) {
      int removed = 0;
      while (platformLevel.isNotEmpty &&
          platformLevel[0].sprite.position.x + platformLevel[0].sprite.width <
              0) {
        platformLevel[0].sprite.remove();
        platformLevel.removeAt(0);
        removed++;
      }
      if (platformLevel.isNotEmpty &&
          platformLevel.length > 3 &&
          random.nextInt(100) > 65 &&
          removed > 0) {
        int secondToLast = platformLevel.length - 4;
        double secondToLastPosition =
            platformLevel.elementAt(secondToLast).sprite.x;
        if (secondToLastPosition > gameRef.size.x) {
          platformLevel[secondToLast].remove();
          platformLevel[secondToLast].sprite.remove();
          platformLevel.removeAt(secondToLast);

          platformLevel[secondToLast + 1].remove();
          platformLevel[secondToLast + 1].sprite.remove();
          platformLevel.removeAt(secondToLast + 1);
        }
      }
    }
  }

  double getFlushX() {
    Platform platform =
        platforms[2].firstWhere((element) => element.sprite.x > 0, orElse: () {
      return platforms[5].firstWhere((element) => element.sprite.x > 0,
          orElse: () {
        return platforms[8].firstWhere((element) => element.sprite.x > 0);
      });
    });
    return platform.sprite.x;
  }

  Platform? getPlatformOffScreen(int level) {
    for (int i = 0; i < platforms[level].length; i++) {
      Platform p = platforms[level][i];
      if (p.sprite.x > p.gameRef.size.x) {
        int chosenIndex = random.nextInt(platforms[level].length - i) + i;
        return platforms[level][chosenIndex];
      }
    }
    return null;
  }
}
