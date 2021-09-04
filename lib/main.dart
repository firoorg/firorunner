import 'package:firo_runner/GameState.dart';
import 'package:firo_runner/MovingObject.dart';
import 'package:firo_runner/Platform.dart';
import 'package:firo_runner/PlatformLoader.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flutter/services.dart';
import 'Runner.dart';

const COLOR = const Color(0xFFDDC0A3);
const SIZE = 52.0;
const GRAVITY = 400.0;
const BOOST = -380.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}

class MyGame extends BaseGame with PanDetector, TapDetector, KeyboardEvents {
  TextPaint textPaint = TextPaint(
    config: TextPaintConfig(fontSize: 48.0),
  );

  late PlatformHolder platformHolder;

  late Sprite background1;
  late Sprite background2;
  late Runner runner;
  late GameState gameState;
  var background;
  late var platform1;
  late var platform2;
  late var platform3;
  late var wire;
  late var bug;
  late var coin;

  var runnerPosition = Vector2(0, 0);
  var runnerSize;
  var backgroundSize;
  var background1Position;
  var background2Position;
  late double blockSize;

  bool loaded = false;

  @override
  Future<void> onLoad() async {
    debugMode = true;
    FlameAudio.bgm.initialize();
    background = await Flame.images.load('bg.png');
    background1 = Sprite(background);
    background2 = Sprite(background);
    platform1 = await Flame.images.load('platform1.png');
    platform2 = await Flame.images.load('platform2.png');
    platform3 = await Flame.images.load('platform3.png');
    wire = await Flame.images.load('wire.png');
    bug = await Flame.images.load('bug.png');
    coin = await Flame.images.load('coin.png');

    platformHolder = PlatformHolder();
    await platformHolder.loadPlatforms();

    gameState = GameState();
    await gameState.load(size);

    runner = Runner();
    await runner.load(loadSpriteAnimation);
    runner.setSize(runnerSize, blockSize);
    runnerPosition = Vector2(blockSize, blockSize * 1);
    runner.setPosition(runnerPosition);
    add(runner);

    // Generate the first 4 Platforms that will always be there at the start.
    for (int i = 0; i < 4; i++) {
      platformHolder.generatePlatform(this, 8, true);
    }
    fillScreen();

    FlameAudio.bgm.play('Infinite_Spankage_M.mp3');
    loaded = true;
  }

  void fillScreen() {
    for (int i = 2; i < 9; i = i + 3) {
      while (!platformHolder.generatePlatform(this, i, false));
    }
  }

  @override
  void render(Canvas canvas) {
    gameState.render(canvas);
    background1.render(
      canvas,
      position: Vector2(0, 0),
      size: Vector2(size.y * (background!.width / background!.height), size.y),
    );
    super.render(canvas);
    platformHolder.render(canvas);
    final fpsCount = fps(1);
    textPaint.render(
      canvas,
      fpsCount.toString(),
      Vector2(0, 0),
    );
  }

  @override
  void update(double dt) {
    platformHolder.removePast(this);
    fillScreen();
    super.update(dt);
    gameState.update(dt);
    platformHolder.update(dt);
  }

  @override
  void onResize(Vector2 size) {
    super.onResize(size);
    blockSize = size.y / 9;
    runnerSize = Vector2(
      size.y / 9,
      size.y / 9,
    );

    if (loaded) {
      backgroundSize =
          Vector2(size.y * (background!.width / background!.height), size.y);
      gameState.setSize(size);
    }
  }

  // Mobile controls
  late List<double> xdeltas;
  late List<double> ydeltas;
  @override
  void onPanStart(DragStartInfo info) {
    xdeltas = List.empty(growable: true);
    ydeltas = List.empty(growable: true);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    xdeltas.add(info.delta.game.x);
    ydeltas.add(info.delta.game.y);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    double xdelta = xdeltas.isEmpty
        ? 0
        : xdeltas.reduce((value, element) => value + element);
    double ydelta = ydeltas.isEmpty
        ? 0
        : ydeltas.reduce((value, element) => value + element);
    if (xdelta.abs() > ydelta.abs()) {
      if (xdelta > 0) {
        runner.control("right");
      } else {
        runner.control("left");
      }
    } else if (xdelta.abs() < ydelta.abs()) {
      if (ydelta > 0) {
        runner.control("down");
      } else {
        runner.control("up");
      }
    }
  }

  @override
  void onTap() {
    runner.control("center");
  }

  // Keyboard controls.
  var keyboardKey;
  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      keyboardKey = null;
      switch (event.data.keyLabel) {
        case "w":
          runner.control("up");
          break;
        case "a":
          runner.control("left");
          break;
        case "s":
          runner.control("down");
          break;
        case "d":
          runner.control("right");
          break;
        default:
          if (event.data.logicalKey.keyId == 32) {
            runner.control("down");
          }
          break;
      }
    }
    if (event is RawKeyDownEvent && event.data.logicalKey.keyId == 32) {
      if (keyboardKey == null) {
        runner.control("center");
      }
      keyboardKey = "spacebar";
    }
  }
}

class Background extends Component {
  static final Paint _paint = Paint()..color = COLOR;
  final size;

  Background(this.size);

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.x, size.y), _paint);
  }

  @override
  void update(double t);
}
