import 'package:firo_runner/holder.dart';
import 'package:flame/flame.dart';

import 'package:firo_runner/coin.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';
import 'package:firo_runner/platform.dart';

class CoinHolder extends Holder {
  late Image coin;

  @override
  Future load() async {
    coin = await Flame.images.load("coin-frames.png");
  }

  Image getCoin() {
    return coin;
  }

  bool generateCoin(MyGame gameRef, int level, bool force) {
    if (total() > 5) {
      return false;
    }

    if (objects[level].isNotEmpty) {
      return false;
    }

    if (random.nextInt(100) > 25) {
      return true;
    } else {
      int nearestPlatform = getNearestPlatform(level);

      Platform? platform =
          gameRef.platformHolder.getPlatformOffScreen(nearestPlatform);
      double xCoordinate = -100;

      if (level == 0) {
        xCoordinate = gameRef.size.x;
      } else if (platform != null) {
        xCoordinate = platform.sprite.x;
      } else {
        return false;
      }

      Coin coin = Coin(gameRef);
      coin.setPosition(xCoordinate, gameRef.blockSize * level);

      if (gameRef.isTooNearOtherObstacles(coin.sprite.toRect())) {
        return false;
      }

      objects[level].add(coin);
      gameRef.add(coin.sprite);
    }
    return false;
  }
}
