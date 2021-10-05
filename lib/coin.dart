import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum CoinState { normal }

class Coin extends MovingObject {
  Coin(MyGame gameRef) : super(gameRef) {
    List<Sprite> coin = gameRef.coinHolder.getCoin();
    SpriteAnimation normal = SpriteAnimation.spriteList(coin, stepTime: 0.1);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        CoinState.normal: normal,
      },
      current: CoinState.normal,
    );

    sprite.changePriorityWithoutResorting(COIN_PRIORITY);

    var platform = gameRef.platformHolder.l1[0].image;

    setSize(
      gameRef.blockSize * (platform.width / platform.height / 2.8),
      gameRef.blockSize * (platform.width / platform.height / 2.8),
    );
  }
}
