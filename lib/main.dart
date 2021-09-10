import 'dart:math';

import 'package:firo_runner/bug_holder.dart';
import 'package:firo_runner/circuit_background.dart';
import 'package:firo_runner/coin_holder.dart';
import 'package:firo_runner/firework.dart';
import 'package:firo_runner/game_state.dart';
import 'package:firo_runner/platform_holder.dart';
import 'package:firo_runner/wire.dart';
import 'package:firo_runner/wire_holder.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firo_runner/bug.dart';
import 'package:firo_runner/coin.dart';
import 'package:firo_runner/runner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const COLOR = Color(0xFFDDC0A3);

const LEVEL2 = 10000000;
const LEVEL3 = 20000000;
const LEVEL4 = 30000000;
const LEVEL5 = 40000000;
const LEVEL6 = 50000000;
const LEVEL7 = 60000000;

const RUNNER_PRIORITY = 100;
const BUG_PRIORITY = 75;
const COIN_PRIORITY = 70;
const PLATFORM_PRIORITY = 50;
const WIRE_PRIORITY = 25;
const FIREWORK_PRIORITY = 15;
const WINDOW_PRIORITY = 10;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}

class MyGame extends BaseGame with PanDetector, TapDetector, KeyboardEvents {
  TextPaint fireworksPaint = TextPaint(
    config: const TextPaintConfig(
        fontSize: 48.0, fontFamily: 'Codystar', color: COLOR),
  );

  late CircuitBackground circuitBackground;
  late PlatformHolder platformHolder;
  late CoinHolder coinHolder;
  late WireHolder wireHolder;
  late BugHolder bugHolder;
  late Firework fireworks;
  Random random = Random();
  bool playingMusic = false;

  late Runner runner;
  late GameState gameState;
  late double blockSize;

  bool loaded = false;
  late Wire wire;

  MyGame() : super() {
    viewport.resize(Vector2(1920, 1080));
  }

  // @override
  // flame.Viewport viewport = FixedResolutionViewport(Vector2(1920, 1080));

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    FlameAudio.bgm.initialize();

    circuitBackground = CircuitBackground(this);
    await circuitBackground.load();
    platformHolder = PlatformHolder();
    await platformHolder.loadPlatforms();
    coinHolder = CoinHolder();
    await coinHolder.loadCoins();
    wireHolder = WireHolder();
    await wireHolder.loadWires();
    bugHolder = BugHolder();
    await bugHolder.loadBugs();
    fireworks = Firework(this);
    await fireworks.load();

    gameState = GameState();

    runner = Runner();
    await runner.load(loadSpriteAnimation);

    if (!kIsWeb) {
      playMusic();
    }
    loaded = true;
    setUp();
  }

  void playMusic() {
    FlameAudio.bgm.play('Infinite_Spankage_M.mp3');
    playingMusic = true;
  }

  void fillScreen() {
    if (shouldReset) {
      return;
    }
    for (int i = 2; i < 9; i = i + 3) {
      while (!platformHolder.generatePlatform(this, i, false)) {}
    }
    int wireChosenRegion = random.nextInt(8) + 1;
    if (wireChosenRegion % 3 != 2) {
      wireHolder.generateWire(this, wireChosenRegion, false);
    }

    int bugChosenRegion = random.nextInt(8) + 1;
    if (bugChosenRegion % 3 != 2) {
      bugHolder.generateBug(this, bugChosenRegion, false);
    }

    int choseCoinLevel = random.nextInt(8) + 1;
    if (choseCoinLevel % 3 != 2) {
      coinHolder.generateCoin(this, choseCoinLevel, false);
    }
  }

  bool isTooNearOtherObstacles(Rect rect) {
    Rect obstacleBounds = Rect.fromLTRB(
        3 * rect.left - 2 * rect.right - 1,
        3 * rect.top - 2 * rect.bottom - 1,
        3 * rect.right - 2 * rect.left + 1,
        3 * rect.bottom - 2 * rect.top + 1);
    for (List<Wire> wireLevel in wireHolder.wires) {
      for (Wire wire in wireLevel) {
        if (wire.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<Coin> coinLevel in coinHolder.coins) {
      for (Coin coin in coinLevel) {
        if (coin.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<Bug> bugLevel in bugHolder.bugs) {
      for (Bug bug in bugLevel) {
        if (bug.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    return false;
  }

  bool shouldReset = false;

  void reset() {
    if (!(runner.sprite.animation?.done() ?? false) &&
        runner.sprite.animation!.loop == false) {
      return;
    }
    runner.sprite.animation!.reset();
    shouldReset = false;
    components.clear();
    setUp();
  }

  void die() {
    gameState.setPaused();
    shouldReset = true;
  }

  void setUp() {
    add(runner);
    fireworks.setUp();
    runner.sprite.clearEffects();
    runner.sprite.current = RunnerState.run;
    circuitBackground.setUp();
    platformHolder.setUp();
    coinHolder.setUp();
    wireHolder.setUp();
    bugHolder.setUp();

    gameState.setUp(this);

    runner.setUp();

    // Generate the first 4 Platforms that will always be there at the start.
    for (int i = 0; i < 4; i++) {
      platformHolder.generatePlatform(this, 8, true);
    }
    fillScreen();
  }

  @override
  void render(Canvas canvas) {
    circuitBackground.render(canvas);
    fireworks.renderText(canvas);
    super.render(canvas);
    final fpsCount = fps(1);
    fireworksPaint.render(
      canvas,
      fpsCount.toString(),
      Vector2(0, 0),
    );
  }

  @override
  void update(double dt) {
    fireworks.update(dt);
    platformHolder.removePast(this);
    coinHolder.removePast(this);
    wireHolder.removePast(this);
    bugHolder.removePast(this);
    fillScreen();
    super.update(dt);
    circuitBackground.update(dt);
    gameState.update(dt);
    platformHolder.update(dt);
    coinHolder.update(dt);
    wireHolder.update(dt);
    bugHolder.update(dt);
    if (shouldReset) {
      reset();
    }
  }

  @override
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);
    blockSize = canvasSize.y / 9;
  }

  // Mobile controls
  late List<double> xDeltas;
  late List<double> yDeltas;
  @override
  void onPanStart(DragStartInfo info) {
    xDeltas = List.empty(growable: true);
    yDeltas = List.empty(growable: true);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    xDeltas.add(info.delta.game.x);
    yDeltas.add(info.delta.game.y);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
    double xDelta = xDeltas.isEmpty
        ? 0
        : xDeltas.reduce((value, element) => value + element);
    double yDelta = yDeltas.isEmpty
        ? 0
        : yDeltas.reduce((value, element) => value + element);
    if (xDelta.abs() > yDelta.abs()) {
      if (xDelta > 0) {
        runner.control("right");
      } else {
        runner.control("left");
      }
    } else if (xDelta.abs() < yDelta.abs()) {
      if (yDelta > 0) {
        runner.control("down");
      } else {
        runner.control("up");
      }
    }
  }

  @override
  void onTap() {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
    runner.control("center");
  }

  // Keyboard controls.
  var keyboardKey;
  @override
  void onKeyEvent(RawKeyEvent event) {
    if (!playingMusic && kIsWeb) {
      playMusic();
    }
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
