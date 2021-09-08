import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum BugState { normal, breaking }

class Bug extends MovingObject {
  Bug(MyGame gameRef) : super(gameRef) {
    var bug = gameRef.bugHolder.getBug("normal");
    var breakingImage = gameRef.bugHolder.getBug("breaking");
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      bug,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation breaking = SpriteAnimation.fromFrameData(
      breakingImage,
      SpriteAnimationData.sequenced(
        amount: 13,
        stepTime: 0.01,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        BugState.normal: normal,
        BugState.breaking: breaking,
      },
      current: BugState.normal,
    );

    sprite.changePriorityWithoutResorting(BUG_PRIORITY);

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
