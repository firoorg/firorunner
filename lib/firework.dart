import 'dart:math';

import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

enum FireworkState { normal }

class Firework extends Component {
  MyGame gameRef;
  late SpriteAnimationGroupComponent sprite1;
  late SpriteAnimationGroupComponent sprite2;
  Firework(this.gameRef);
  double timeSinceFirework = 0;
  late Random random;
  String message = "";
  List<String> messages = [
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
    "Speed Up!",
  ];

  Future load() async {
    random = Random();
    Image firework = await Flame.images.load("fireworks-frames.png");

    SpriteAnimation normal = SpriteAnimation.fromFrameData(
      firework,
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.25,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    sprite1 = SpriteAnimationGroupComponent(
      animations: {
        FireworkState.normal: normal,
      },
      current: FireworkState.normal,
    );

    sprite1.changePriorityWithoutResorting(FIREWORK_PRIORITY);
    sprite1.update(100);

    sprite1.size =
        Vector2(gameRef.viewport.canvasSize.y, gameRef.viewport.canvasSize.y);
    sprite1.position = Vector2(0, 0);

    sprite2 = SpriteAnimationGroupComponent(
      animations: {
        FireworkState.normal: normal,
      },
      current: FireworkState.normal,
    );

    sprite2.changePriorityWithoutResorting(FIREWORK_PRIORITY);

    sprite2.size =
        Vector2(gameRef.viewport.canvasSize.y, gameRef.viewport.canvasSize.y);
    sprite2.position =
        Vector2(gameRef.viewport.canvasSize.x - sprite2.size.x, 0);
    sprite2.update(100);
  }

  void setUp() {
    message = "";
    timeSinceFirework = 0;
    gameRef.add(sprite1);
    gameRef.add(sprite2);
  }

  @override
  void update(double dt) {
    if (!(sprite1.animation?.done() ?? false)) {
      timeSinceFirework = 0;
    } else {
      timeSinceFirework += dt;
    }
    sprite1.update(dt);
    sprite2.update(dt);
  }

  void renderText(Canvas canvas) {
    sprite1.render(canvas);
    sprite1.render(canvas);
    if ((sprite1.animation?.done() ?? false) &&
        timeSinceFirework < 1 &&
        message != "") {
      gameRef.fireworksPaint.render(
        canvas,
        message,
        Vector2(
            gameRef.size.x / 2 -
                gameRef.fireworksPaint.measureTextWidth(message) / 2,
            gameRef.size.y / 9 -
                gameRef.fireworksPaint.measureTextHeight(message) / 2),
      );
    }
  }

  void reset() {
    message = messages.elementAt(random.nextInt(messages.length));
    sprite1.animation!.reset();
    sprite2.animation!.reset();
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    sprite1.x *= xRatio;
    sprite1.y *= yRatio;
    sprite1.width *= xRatio;
    sprite1.height *= yRatio;

    sprite2.x *= xRatio;
    sprite2.y *= yRatio;
    sprite2.width *= xRatio;
    sprite2.height *= yRatio;
  }
}
