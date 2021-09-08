import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/extensions.dart';

enum WindowState {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
}

class CircuitBackground extends MovingObject {
  late Image background;
  late Image windows0;
  late Image windows1;
  late Image windows2;
  late Image windows3;
  late Image windows4;
  late Image windows5;
  late Image windows6;

  late Sprite background1;
  late Sprite background2;
  late SpriteAnimationGroupComponent windowA;
  late SpriteAnimationGroupComponent windowB;
  Vector2 background1Size = Vector2(0, 0);
  Vector2 background2Size = Vector2(0, 0);
  Vector2 background1Position = Vector2(0, 0);
  Vector2 background2Position = Vector2(0, 0);

  CircuitBackground(MyGame gameRef) : super(gameRef);

  Future load() async {
    background = await Flame.images.load("bg.png");
    background1 = Sprite(background);
    background2 = Sprite(background);

    windows0 = await Flame.images.load("windows-0.png");
    windows1 = await Flame.images.load("windows-1.png");
    windows2 = await Flame.images.load("windows-2.png");
    windows3 = await Flame.images.load("windows-3.png");
    windows4 = await Flame.images.load("windows-4.png");
    windows5 = await Flame.images.load("windows-5.png");
    windows6 = await Flame.images.load("windows-6.png");

    SpriteAnimation first = SpriteAnimation.fromFrameData(
        windows0,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation second = SpriteAnimation.fromFrameData(
        windows1,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation third = SpriteAnimation.fromFrameData(
        windows2,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation fourth = SpriteAnimation.fromFrameData(
        windows3,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation fifth = SpriteAnimation.fromFrameData(
        windows4,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation sixth = SpriteAnimation.fromFrameData(
        windows5,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    SpriteAnimation seventh = SpriteAnimation.fromFrameData(
        windows6,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(6000, 2000),
            loop: false));

    windowA = SpriteAnimationGroupComponent(
      animations: {
        WindowState.first: first,
        WindowState.second: second,
        WindowState.third: third,
        WindowState.fourth: fourth,
        WindowState.fifth: fifth,
        WindowState.sixth: sixth,
        WindowState.seventh: seventh,
      },
      current: WindowState.first,
    );

    windowB = SpriteAnimationGroupComponent(
      animations: {
        WindowState.first: first,
        WindowState.second: second,
        WindowState.third: third,
        WindowState.fourth: fourth,
        WindowState.fifth: fifth,
        WindowState.sixth: sixth,
        WindowState.seventh: seventh,
      },
      current: WindowState.first,
    );

    setUp();
  }

  void setUp() {
    windowA.current = WindowState.first;
    windowB.current = WindowState.first;
    gameRef.add(windowA);
    gameRef.add(windowB);
    background1Position = Vector2(0, 0);
    background1Size = Vector2(
        gameRef.size.y * (background.width / background.height),
        gameRef.size.y);
    windowA.position = background1Position;
    windowA.size = background1Size;

    background2Position =
        Vector2(background1Position.x + background1Size.x - 1, 0);
    background2Size = Vector2(
        gameRef.size.y * (background.width / background.height),
        gameRef.size.y);
    windowB.position = background2Position;
    windowB.size = background2Size;
  }

  @override
  void update(double dt) {
    switch (gameRef.gameState.getLevel()) {
      case 7:
        gameRef.circuitBackground.windowA.current = WindowState.seventh;
        gameRef.circuitBackground.windowB.current = WindowState.seventh;
        break;
      case 6:
        gameRef.circuitBackground.windowA.current = WindowState.sixth;
        gameRef.circuitBackground.windowB.current = WindowState.sixth;
        break;
      case 5:
        gameRef.circuitBackground.windowA.current = WindowState.fifth;
        gameRef.circuitBackground.windowB.current = WindowState.fifth;
        break;
      case 4:
        gameRef.circuitBackground.windowA.current = WindowState.fourth;
        gameRef.circuitBackground.windowB.current = WindowState.fourth;
        break;
      case 3:
        gameRef.circuitBackground.windowA.current = WindowState.third;
        gameRef.circuitBackground.windowB.current = WindowState.third;
        break;
      case 2:
        gameRef.circuitBackground.windowA.current = WindowState.second;
        gameRef.circuitBackground.windowB.current = WindowState.second;
        break;
      default:
        gameRef.circuitBackground.windowA.current = WindowState.first;
        gameRef.circuitBackground.windowB.current = WindowState.first;
        break;
    }
    windowA.update(dt);
    windowB.update(dt);
    if (background1Position.x + background1Size.x < 0) {
      double newPosition = background2Position.x + background2Size.x;
      background1Position = Vector2(newPosition - 1, 0);
    } else if (background2Position.x + background2Size.x < 0) {
      double newPosition = background1Position.x + background1Size.x;
      background2Position = Vector2(newPosition - 1, 0);
    }

    double velocity = gameRef.gameState.getVelocity() / 10.0;
    background1Position = background1Position - Vector2(velocity * dt, 0);
    windowA.position = background1Position;
    background2Position = background2Position - Vector2(velocity * dt, 0);
    windowB.position = background2Position;
  }

  void render(Canvas canvas) {
    background1.render(canvas,
        size: background1Size, position: background1Position);
    // windowA.render(canvas);
    background2.render(canvas,
        size: background2Size, position: background2Position);
    // windowB.render(canvas);
  }
}
