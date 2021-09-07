import 'package:firo_runner/MovingObject.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum WireState { normal }

class Wire extends MovingObject {
  Wire(MyGame gameRef) : super(gameRef) {
    var wire = gameRef.wireHolder.getWire();
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      wire,
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: 0.05,
        textureSize: Vector2(512, 512),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        WireState.normal: normal,
      },
      current: WireState.normal,
    );

    sprite.changePriorityWithoutResorting(WIRE_PRIORITY);

    setSize(
      gameRef.blockSize,
      gameRef.blockSize,
    );
  }

  double getRightEnd() {
    return sprite.position.x + sprite.width;
  }

  void remove() {
    sprite.remove();
  }
}
