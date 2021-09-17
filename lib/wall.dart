import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

enum WallState { normal }

class Wall extends MovingObject {
  int direction = -1;
  late int bottomPlatformLevel;
  Wall(MyGame gameRef) : super(gameRef) {
    var wall = gameRef.wallHolder.getWall();
    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      wall,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(163, 1000),
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        WallState.normal: normal,
      },
      current: WallState.normal,
    );

    sprite.changePriorityWithoutResorting(WALL_PRIORITY);

    setSize(
      gameRef.blockSize *
          (gameRef.wallHolder.wall.width / gameRef.wallHolder.wall.height / 5) *
          2.0,
      gameRef.blockSize * 0.5,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    int nearestPlatform =
        getNearestPlatform((sprite.x / gameRef.blockSize).round());
    nearestPlatform = nearestPlatform == 0 ? -1 : nearestPlatform;
    if (sprite.y + sprite.height > bottomPlatformLevel * gameRef.blockSize) {
      direction = -1;
    } else if ((bottomPlatformLevel - 2) * gameRef.blockSize -
            2 * gameRef.blockSize / 7 >
        sprite.y) {
      direction = 1;
    }
    double velocity = gameRef.gameState.getVelocity() / 10.0;
    sprite.position = sprite.position + Vector2(0, direction * velocity * dt);
  }
}
