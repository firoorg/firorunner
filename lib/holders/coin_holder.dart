import 'package:firo_runner/holders/holder.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/coin.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';
import 'package:firo_runner/moving_objects/platform.dart';

class CoinHolder extends Holder {
  late List<Sprite> coin;
  late SpriteAnimationGroupComponent sprite;
  late MyGame personalGameRef;

  @override
  Future load() async {
    coin = await loadListSprites("coin", "coin", 12);
    SpriteAnimation normal = SpriteAnimation.spriteList(coin, stepTime: 0.1);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        CoinState.normal: normal,
      },
      current: CoinState.normal,
    );

    sprite.changePriorityWithoutResorting(COIN_PRIORITY);

    sprite.size = Vector2(20, 20);
  }

  void setPersonalGameRef(MyGame gameRef) {
    personalGameRef = gameRef;
  }

  @override
  void resize(Vector2 newSize, double xRatio, double yRatio) {
    super.resize(newSize, xRatio, yRatio);
    sprite.x *= xRatio;
    sprite.y *= yRatio;
    sprite.width *= xRatio;
    sprite.height *= yRatio;
  }

  void renderCoinScore(Canvas c) {
    sprite.position = Vector2(personalGameRef.size.x - 70, 10);
    sprite.render(c);
  }

  List<Sprite> getCoin() {
    return coin;
  }

  bool generateCoin(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0}) {
    if (total() > 5 && !force) {
      return false;
    }

    if (objects[level].isNotEmpty && !force) {
      return false;
    }

    if (random.nextInt(100) > 25 && !force) {
      return true;
    } else {
      int nearestPlatform = getNearestPlatform(level);

      Platform? platform =
          gameRef.platformHolder.getPlatformOffScreen(nearestPlatform);
      double xCoordinate = -100;

      if (force) {
        xCoordinate = xPosition;
      } else if (level == 0) {
        xCoordinate = gameRef.size.x;
      } else if (platform != null) {
        xCoordinate = platform.sprite.x;
      } else {
        return false;
      }

      Coin coin = Coin(gameRef);
      coin.setPosition(xCoordinate, gameRef.blockSize * level);

      if (gameRef.isTooNearOtherObstacles(coin.sprite.toRect()) && !force) {
        return false;
      }

      objects[level].add(coin);
      gameRef.add(coin.sprite);
    }
    return false;
  }
}
