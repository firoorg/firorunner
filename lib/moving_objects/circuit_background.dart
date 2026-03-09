import 'package:firo_runner/biome.dart';
import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

enum WindowState {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
}

enum OverlayState {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
}

// Class for the moving background.
class CircuitBackground extends MovingObject {
  late Image background;

  late Image overlay0;
  late Image overlay1;
  late Image overlay2;
  late Image overlay3;
  late Image overlay4;
  late Image overlay5;
  late Image overlay6;

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
  late SpriteAnimationGroupComponent overlayA;
  late SpriteAnimationGroupComponent overlayB;
  Vector2 background1Size = Vector2(0, 0);
  Vector2 background2Size = Vector2(0, 0);
  Vector2 background1Position = Vector2(0, 0);
  Vector2 background2Position = Vector2(0, 0);

  CircuitBackground(MyGame gameRef) : super(gameRef);

  Future load() async {
    background = await Flame.images.load("bg.png");
    background1 = Sprite(background);
    background2 = Sprite(background);

    overlay0 = await Flame.images.load("overlay100.png");
    overlay1 = await Flame.images.load("overlay90.png");
    overlay2 = await Flame.images.load("overlay80.png");
    overlay3 = await Flame.images.load("overlay70.png");
    overlay4 = await Flame.images.load("overlay60.png");
    overlay5 = await Flame.images.load("overlay50.png");
    overlay6 = await Flame.images.load("overlay40.png");

    SpriteAnimation firstOverlay = SpriteAnimation.fromFrameData(
        overlay0,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation secondOverlay = SpriteAnimation.fromFrameData(
        overlay1,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation thirdOverlay = SpriteAnimation.fromFrameData(
        overlay2,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation fourthOverlay = SpriteAnimation.fromFrameData(
        overlay3,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation fifthOverlay = SpriteAnimation.fromFrameData(
        overlay4,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation sixthOverlay = SpriteAnimation.fromFrameData(
        overlay5,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation seventhOverlay = SpriteAnimation.fromFrameData(
        overlay6,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    overlayA = SpriteAnimationGroupComponent(
      animations: {
        OverlayState.first: firstOverlay,
        OverlayState.second: secondOverlay,
        OverlayState.third: thirdOverlay,
        OverlayState.fourth: fourthOverlay,
        OverlayState.fifth: fifthOverlay,
        OverlayState.sixth: sixthOverlay,
        OverlayState.seventh: seventhOverlay,
      },
      current: OverlayState.first,
    );

    overlayB = SpriteAnimationGroupComponent(
      animations: {
        OverlayState.first: firstOverlay,
        OverlayState.second: secondOverlay,
        OverlayState.third: thirdOverlay,
        OverlayState.fourth: fourthOverlay,
        OverlayState.fifth: fifthOverlay,
        OverlayState.sixth: sixthOverlay,
        OverlayState.seventh: seventhOverlay,
      },
      current: OverlayState.first,
    );

    overlayA.changePriorityWithoutResorting(WINDOW_PRIORITY - 1);

    overlayA.changePriorityWithoutResorting(WINDOW_PRIORITY - 1);

    windows0 = await Flame.images.load("windows-0.png");
    windows1 = await Flame.images.load("windows-1.png");
    windows2 = await Flame.images.load("windows-2.png");
    windows3 = await Flame.images.load("windows-3.png");
    windows4 = await Flame.images.load("windows-4.png");
    windows5 = await Flame.images.load("windows-5.png");
    windows6 = await Flame.images.load("windows-6.png");

    SpriteAnimation firstWindow = SpriteAnimation.fromFrameData(
        windows0,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation secondWindow = SpriteAnimation.fromFrameData(
        windows1,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation thirdWindow = SpriteAnimation.fromFrameData(
        windows2,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation fourthWindow = SpriteAnimation.fromFrameData(
        windows3,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation fifthWindow = SpriteAnimation.fromFrameData(
        windows4,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation sixthWindow = SpriteAnimation.fromFrameData(
        windows5,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    SpriteAnimation seventhWindow = SpriteAnimation.fromFrameData(
        windows6,
        SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(2048, 683),
            loop: false));

    windowA = SpriteAnimationGroupComponent(
      animations: {
        WindowState.first: firstWindow,
        WindowState.second: secondWindow,
        WindowState.third: thirdWindow,
        WindowState.fourth: fourthWindow,
        WindowState.fifth: fifthWindow,
        WindowState.sixth: sixthWindow,
        WindowState.seventh: seventhWindow,
      },
      current: WindowState.first,
    );

    windowB = SpriteAnimationGroupComponent(
      animations: {
        WindowState.first: firstWindow,
        WindowState.second: secondWindow,
        WindowState.third: thirdWindow,
        WindowState.fourth: fourthWindow,
        WindowState.fifth: fifthWindow,
        WindowState.sixth: sixthWindow,
        WindowState.seventh: seventhWindow,
      },
      current: WindowState.first,
    );

    windowA.changePriorityWithoutResorting(WINDOW_PRIORITY);

    windowA.changePriorityWithoutResorting(WINDOW_PRIORITY);

    setUp();
  }

  void setUp() {
    windowA.current = WindowState.first;
    windowB.current = WindowState.first;
    overlayA.current = OverlayState.first;
    overlayB.current = OverlayState.first;
    background1Position = Vector2(0, 0);
    background1Size = Vector2(
        gameRef.viewport.canvasSize.y * (background.width / background.height),
        gameRef.viewport.canvasSize.y);
    windowA.position = background1Position;
    windowA.size = background1Size;
    overlayA.position = background1Position;
    overlayA.size = background1Size;

    background2Position =
        Vector2(background1Position.x + background1Size.x - 1, 0);
    background2Size = Vector2(
        gameRef.viewport.canvasSize.y * (background.width / background.height),
        gameRef.viewport.canvasSize.y);
    windowB.position = background2Position;
    windowB.size = background2Size;
    overlayB.position = background2Position;
    overlayB.size = background2Size;
  }

  @override
  void update(double dt) {
    int scoreLevel = gameRef.gameState.getScoreLevel();

    // For score levels 0-12 (city biome), use original window/overlay system.
    if (scoreLevel <= 12) {
      switch (scoreLevel) {
        case 12:
          windowA.current = WindowState.seventh;
          windowB.current = WindowState.seventh;
          break;
        case 11:
          overlayA.current = OverlayState.seventh;
          overlayB.current = OverlayState.seventh;
          break;
        case 10:
          windowA.current = WindowState.sixth;
          windowB.current = WindowState.sixth;
          break;
        case 9:
          overlayA.current = OverlayState.sixth;
          overlayB.current = OverlayState.sixth;
          break;
        case 8:
          windowA.current = WindowState.fifth;
          windowB.current = WindowState.fifth;
          break;
        case 7:
          overlayA.current = OverlayState.fifth;
          overlayB.current = OverlayState.fifth;
          break;
        case 6:
          windowA.current = WindowState.fourth;
          windowB.current = WindowState.fourth;
          break;
        case 5:
          overlayA.current = OverlayState.fourth;
          overlayB.current = OverlayState.fourth;
          break;
        case 4:
          windowA.current = WindowState.third;
          windowB.current = WindowState.third;
          break;
        case 3:
          overlayA.current = OverlayState.third;
          overlayB.current = OverlayState.third;
          break;
        case 2:
          windowA.current = WindowState.second;
          windowB.current = WindowState.second;
          break;
        case 1:
          overlayA.current = OverlayState.second;
          overlayB.current = OverlayState.second;
          break;
        default:
          windowA.current = WindowState.first;
          windowB.current = WindowState.first;
          overlayA.current = OverlayState.first;
          overlayB.current = OverlayState.first;
          break;
      }
    } else {
      // For biome levels beyond city, use the final window/overlay state
      // and let the biome tint handle the visual differentiation.
      windowA.current = WindowState.seventh;
      windowB.current = WindowState.seventh;
      overlayA.current = OverlayState.seventh;
      overlayB.current = OverlayState.seventh;
    }

    windowA.update(dt);
    windowB.update(dt);
    overlayA.update(dt);
    overlayB.update(dt);
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
    overlayA.position = background1Position;
    background2Position = background2Position - Vector2(velocity * dt, 0);
    windowB.position = background2Position;
    overlayB.position = background2Position;
  }

  void render(Canvas canvas) {
    BiomeConfig biomeConfig = gameRef.gameState.getCurrentBiomeConfig();
    Biome currentBiome = gameRef.gameState.currentBiome;

    // Render first background panel.
    background1.render(canvas,
        size: background1Size, position: background1Position);

    if (currentBiome == Biome.city) {
      // City biome: use the original overlay and window system.
      canvas.save();
      overlayA.render(canvas);
      canvas.restore();
      canvas.save();
      windowA.render(canvas);
      canvas.restore();
    }

    // Render second background panel.
    background2.render(canvas,
        size: background2Size, position: background2Position);

    if (currentBiome == Biome.city) {
      canvas.save();
      overlayB.render(canvas);
      canvas.restore();
      canvas.save();
      windowB.render(canvas);
      canvas.restore();
    }

    // For non-city biomes, draw biome atmosphere and tint overlays.
    if (currentBiome != Biome.city) {
      // Draw the biome background tint over the entire scene.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.viewport.canvasSize.x,
            gameRef.viewport.canvasSize.y),
        Paint()
          ..color = biomeConfig.backgroundTint.withOpacity(0.35)
          ..blendMode = BlendMode.srcATop,
      );

      // Draw atmosphere overlay for mood.
      if (biomeConfig.atmosphereOpacity > 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, gameRef.viewport.canvasSize.x,
              gameRef.viewport.canvasSize.y),
          Paint()
            ..color = biomeConfig.atmosphereColor
                .withOpacity(biomeConfig.atmosphereOpacity),
        );
      }

      // Draw biome-specific environmental elements.
      _renderBiomeEnvironment(canvas, currentBiome, biomeConfig);
    }
  }

  /// Renders additional environment details specific to each biome.
  void _renderBiomeEnvironment(
      Canvas canvas, Biome biome, BiomeConfig config) {
    double canvasW = gameRef.viewport.canvasSize.x;
    double canvasH = gameRef.viewport.canvasSize.y;

    switch (biome) {
      case Biome.grassland:
        // Draw a green gradient ground hint at the bottom.
        canvas.drawRect(
          Rect.fromLTWH(0, canvasH * 0.85, canvasW, canvasH * 0.15),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x004CAF50), Color(0x554CAF50)],
            ).createShader(
                Rect.fromLTWH(0, canvasH * 0.85, canvasW, canvasH * 0.15)),
        );
        break;

      case Biome.forest:
        // Dark canopy shadow at the top.
        canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasW, canvasH * 0.2),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x660d260d), Color(0x000d260d)],
            ).createShader(Rect.fromLTWH(0, 0, canvasW, canvasH * 0.2)),
        );
        // Mossy ground.
        canvas.drawRect(
          Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00355E3B), Color(0x66355E3B)],
            ).createShader(
                Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12)),
        );
        break;

      case Biome.desert:
        // Heat shimmer at the top.
        canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasW, canvasH * 0.15),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x44FF6600), Color(0x00FF6600)],
            ).createShader(Rect.fromLTWH(0, 0, canvasW, canvasH * 0.15)),
        );
        // Sandy ground.
        canvas.drawRect(
          Rect.fromLTWH(0, canvasH * 0.87, canvasW, canvasH * 0.13),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00C2B280), Color(0x66C2B280)],
            ).createShader(
                Rect.fromLTWH(0, canvasH * 0.87, canvasW, canvasH * 0.13)),
        );
        break;

      case Biome.tundra:
        // Frosty top.
        canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasW, canvasH * 0.1),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55E0FFFF), Color(0x00E0FFFF)],
            ).createShader(Rect.fromLTWH(0, 0, canvasW, canvasH * 0.1)),
        );
        // Snowy ground.
        canvas.drawRect(
          Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), Color(0x77FFFFFF)],
            ).createShader(
                Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12)),
        );
        break;

      case Biome.utopia:
        // Luminous glow from top.
        canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasW, canvasH * 0.2),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x449b59b6), Color(0x009b59b6)],
            ).createShader(Rect.fromLTWH(0, 0, canvasW, canvasH * 0.2)),
        );
        // Neon ground glow.
        canvas.drawRect(
          Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x001abc9c), Color(0x551abc9c)],
            ).createShader(
                Rect.fromLTWH(0, canvasH * 0.88, canvasW, canvasH * 0.12)),
        );
        break;

      case Biome.city:
        // City uses the original overlay/window system, no extra rendering.
        break;
    }
  }

  @override
  void resize(Vector2 newSize, double xRatio, double yRatio) {
    background1Position.x *= xRatio;
    background1Position.y *= yRatio;
    background1Size.x *= xRatio;
    background1Size.y *= yRatio;
    background2Position.x *= xRatio;
    background2Position.y *= yRatio;
    background2Size.x *= xRatio;
    background2Size.y *= yRatio;
    windowA.position = background1Position;
    windowA.size = background1Size;
    overlayA.position = background1Position;
    overlayA.size = background1Size;
    windowB.position = background2Position;
    windowB.size = background2Size;
    overlayB.position = background2Position;
    overlayB.size = background2Size;
  }
}
