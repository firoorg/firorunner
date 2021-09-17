import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum DebrisState { normal }

class Debris extends MovingObject {
  Debris(MyGame gameRef) : super(gameRef) {
    var debris = gameRef.debrisHolder.getDebris();
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      debris,
      SpriteAnimationData.sequenced(
        amount: 21,
        stepTime: 0.1,
        textureSize: Vector2(360, 1000),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        DebrisState.normal: normal,
      },
      current: DebrisState.normal,
    );

    sprite.changePriorityWithoutResorting(DEBRIS_PRIORITY);

    setSize(
      gameRef.blockSize *
          (gameRef.debrisHolder.debris.width /
              gameRef.debrisHolder.debris.height /
              21) *
          1.5,
      gameRef.blockSize * 1.5,
    );
  }
}
