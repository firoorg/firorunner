import 'dart:math';

import 'package:firo_runner/MovingObject.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum PlatformState { normal }

class Platform extends MovingObject {
  List<Function> removeChildren = [];

  Platform(MyGame gameRef) : super(gameRef) {
    var random = Random();
    int version = random.nextInt(3) + 1;
    var platform = gameRef.platformHolder.getPlatform(version);
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      platform,
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(800, 510),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        PlatformState.normal: normal,
      },
      current: PlatformState.normal,
    );

    sprite.changePriorityWithoutResorting(PLATFORM_PRIORITY);

    setSize(
      gameRef.blockSize * (platform!.width / platform!.height / 7),
      gameRef.blockSize,
    );
  }

  double getRightEnd() {
    return sprite.position.x + sprite.width;
  }

  void remove() {
    if (removeChildren.isNotEmpty) {
      for (Function removeChild in removeChildren) {
        removeChild();
      }
    }
  }
}
