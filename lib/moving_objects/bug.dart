import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum BugState { normal, breaking }

class Bug extends MovingObject {
  Bug(MyGame gameRef) : super(gameRef) {
    List<Sprite> bug = gameRef.bugHolder.getBug("normal");
    List<Sprite> breakingImage = gameRef.bugHolder.getBug("breaking");
    SpriteAnimation normal = SpriteAnimation.spriteList(bug, stepTime: 0.1);

    SpriteAnimation breaking =
        SpriteAnimation.spriteList(breakingImage, stepTime: 0.01, loop: false);

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
}
