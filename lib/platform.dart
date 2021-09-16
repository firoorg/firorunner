import 'dart:math';

import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum PlatformState {
  left,
  mid,
  right,
  single,
}

class Platform extends MovingObject {
  int row = 0;
  bool prohibitObstacles = false;
  List<Function> removeChildren = [];

  Platform(MyGame gameRef) : super(gameRef) {
    var random = Random();

    int version = random.nextInt(2);

    SpriteAnimation left = SpriteAnimation.fromFrameData(
      version == 0 ? gameRef.platformHolder.l1 : gameRef.platformHolder.l2,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.12,
        textureSize: Vector2(1000, 807),
      ),
    );

    SpriteAnimation mid = SpriteAnimation.fromFrameData(
      version == 0 ? gameRef.platformHolder.m1 : gameRef.platformHolder.m2,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.12,
        textureSize: Vector2(1000, 807),
      ),
    );

    SpriteAnimation right = SpriteAnimation.fromFrameData(
      version == 0 ? gameRef.platformHolder.r1 : gameRef.platformHolder.r2,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.12,
        textureSize: Vector2(1000, 807),
      ),
    );

    SpriteAnimation single = SpriteAnimation.fromFrameData(
      version == 0 ? gameRef.platformHolder.o1 : gameRef.platformHolder.o2,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.12,
        textureSize: Vector2(1000, 807),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        PlatformState.left: left,
        PlatformState.mid: mid,
        PlatformState.right: right,
        PlatformState.single: single,
      },
      current: PlatformState.single,
    );

    sprite.changePriorityWithoutResorting(PLATFORM_PRIORITY);

    setSize(
      gameRef.blockSize *
          (gameRef.platformHolder.l1.width /
              gameRef.platformHolder.l1.height /
              5),
      gameRef.blockSize,
    );
  }

  @override
  void remove() {
    removeChildrenObjects();
    super.remove();
  }

  void removeChildrenObjects() {
    if (removeChildren.isNotEmpty) {
      for (Function removeChild in removeChildren) {
        removeChild();
      }
    }
  }

  @override
  void update(double dt) {
    List<MovingObject> platformLevel = gameRef.platformHolder.objects[row];
    int index = platformLevel.indexOf(this);
    Vector2 right = Vector2(-200, -200);
    if (index + 1 < platformLevel.length) {
      right = platformLevel.elementAt(index + 1).sprite.position;
    }
    super.update(dt);
    if (index == -1 || (index < 1 && sprite.x <= sprite.width)) {
      return;
    }
    Vector2 left = Vector2(-200, -200);
    if (index - 1 >= 0) {
      left = platformLevel.elementAt(index - 1).sprite.position;
    }

    bool hasLeft = (left.x - sprite.position.x).abs() < 1.9 * sprite.size.x;
    bool hasRight = (sprite.position.x - right.x).abs() < 1.9 * sprite.size.x;

    if (hasLeft && hasRight) {
      sprite.current = PlatformState.mid;
    } else if (hasLeft && !hasRight) {
      sprite.current = PlatformState.right;
    } else if (!hasLeft && hasRight) {
      sprite.current = PlatformState.left;
    } else {
      sprite.current = PlatformState.single;
    }
  }
}
