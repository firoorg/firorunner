import 'package:firo_runner/MovingObject.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum CoinState { normal }

class Coin extends MovingObject {
  Coin(MyGame gameRef) : super(gameRef) {
    var coin = gameRef.coinHolder.getCoin();
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      coin,
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        CoinState.normal: normal,
      },
      current: CoinState.normal,
    );

    sprite.changePriorityWithoutResorting(COIN_PRIORITY);

    var platform = gameRef.platformHolder.l1;

    setSize(
      gameRef.blockSize * (platform!.width / platform!.height / 14),
      gameRef.blockSize * (platform!.width / platform!.height / 14),
    );
  }

  double getRightEnd() {
    return sprite.position.x + sprite.width;
  }

  void remove() {
    sprite.remove();
  }
}
