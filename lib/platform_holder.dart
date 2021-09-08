import 'dart:math';

import 'package:firo_runner/main.dart';
import 'package:flame/flame.dart';
import 'package:firo_runner/platform.dart';
import 'package:flame/extensions.dart';

class PlatformHolder {
  late Image l1;
  late Image l2;
  late Image m1;
  late Image m2;
  late Image r1;
  late Image r2;
  late Image o1;
  late Image o2;
  late List<List<Platform>> platforms = [];
  Random random = Random();

  Future loadPlatforms() async {
    l1 = await Flame.images.load('platform-left-nowire-frames.png');
    l2 = await Flame.images.load('platform-left-wire-frames.png');
    m1 = await Flame.images.load('platform-mid-nowire-frames.png');
    m2 = await Flame.images.load('platform-mid-wire-frames.png');
    r1 = await Flame.images.load('platform-right-nowire-frames.png');
    r2 = await Flame.images.load('platform-right-wire-frames.png');
    o1 = await Flame.images.load('platform-single-nowire-frames.png');
    o2 = await Flame.images.load('platform-single-wire-frames.png');
  }

  void setUp() {
    for (int i = 0; i < platforms.length; i++) {
      for (int j = 0; j < platforms[i].length; j++) {
        remove(platforms[i], j);
      }
    }
    platforms = [];
    for (int i = 0; i < 9; i++) {
      platforms.add([]);
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
      platform.row = level;
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

  void remove(List<Platform> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder[j].sprite.remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<Platform> platformLevel in platforms) {
      int removed = 0;
      while (platformLevel.isNotEmpty &&
          platformLevel[0].sprite.position.x + platformLevel[0].sprite.width <
              0) {
        remove(platformLevel, 0);
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
          remove(platformLevel, secondToLast + 1);
          remove(platformLevel, secondToLast);
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
