import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firo_runner/bug_holder.dart';
import 'package:firo_runner/circuit_background.dart';
import 'package:firo_runner/coin_holder.dart';
import 'package:firo_runner/debris_holder.dart';
import 'package:firo_runner/firework.dart';
import 'package:firo_runner/game_state.dart';
import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/platform.dart';
import 'package:firo_runner/platform_holder.dart';
import 'package:firo_runner/wall_holder.dart';
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
import 'package:firo_runner/runner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'package:firo_runner/lose_menu_overlay.dart';
import 'package:firo_runner/main_menu_overlay.dart';

const COLOR = Color(0xFFDDC0A3);
const int LOADING_TIME = 2000000;

const LEVEL2 = 25000000;
const LEVEL3 = 50000000;
const LEVEL4 = 75000000;
const LEVEL5 = 100000000;
const LEVEL6 = 125000000;
const LEVEL7 = 150000000;

const COINS_ROBOT_UPGRADE1 = 50;
const COINS_ROBOT_UPGRADE2 = 100;

const OVERLAY_PRIORITY = 110;
const RUNNER_PRIORITY = 100;
const BUG_PRIORITY = 75;
const COIN_PRIORITY = 70;
const PLATFORM_PRIORITY = 50;
const WALL_PRIORITY = 40;
const DEBRIS_PRIORITY = 30;
const WIRE_PRIORITY = 25;
const FIREWORK_PRIORITY = 15;
const WINDOW_PRIORITY = 10;

// const overlayText = TextStyle(
//   fontSize: 30,
//   color: Colors.white,
// );

const AssetImage mainMenuImage = AssetImage('assets/images/mm3.gif');
const AssetImage lossImage = AssetImage('assets/images/overlay100.png');
const AssetImage buttonImage = AssetImage('assets/images/button-new.png');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  final myGame = MyGame();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget<MyGame>(
        game: myGame,
        overlayBuilderMap: {
          // Should be used once before all overlays are called. Flame has a slight
          // delay when constructing the overlay widgets, so to make the text and
          // images load together, all the other overlays should be called in the
          // load section, and removed, and the loading black screen should be kept
          // up until everything is finished loading.
          'loading': (_, myGame) {
            return Center(
              child: Container(
                height: myGame.viewport.canvasSize.y,
                width: myGame.viewport.canvasSize.x,
                color: Colors.black,
              ),
            );
          },
          'mainMenu': (_, myGame) {
            return MainMenuOverlay(game: myGame);
          },
          'gameOver': (_, myGame) {
            return LoseMenuOverlay(game: myGame);
          },
        },
      )));
}

int getNearestPlatform(int level) {
  return level <= 0
      ? 0
      : level <= 3
          ? 2
          : level <= 6
              ? 5
              : 8;
}

class MyGame extends BaseGame with PanDetector, TapDetector, KeyboardEvents {
  TextPaint fireworksPaint = TextPaint(
    config: const TextPaintConfig(
        fontSize: 48.0, fontFamily: 'Codystar', color: COLOR),
  );

  TextPaint scoresPaint = TextPaint(
    config: const TextPaintConfig(fontSize: 16.0, color: COLOR),
  );

  late CircuitBackground circuitBackground;
  late PlatformHolder platformHolder;
  late CoinHolder coinHolder;
  late WireHolder wireHolder;
  late BugHolder bugHolder;
  late Firework fireworks;
  late DebrisHolder debrisHolder;
  late WallHolder wallHolder;
  Random random = Random();
  bool playingMusic = false;

  late Runner runner;
  late GameState gameState;
  late double blockSize;

  bool loaded = false;
  bool firstDeath = true;
  late Wire wire;
  late TextComponent _distance;
  late TextComponent _coins;
  int startLoading = 0;

  MyGame() : super() {
    viewport.resize(Vector2(1920, 1080));
  }

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache.loadAll([
      'sfx/bug_chomp.mp3',
      'sfx/coin_catch.mp3',
      'sfx/fall_death.mp3',
      'sfx/glitch_death.mp3',
      'sfx/jet_boost.mp3',
      'sfx/menu_button.mp3',
      'sfx/obstacle_death.mp3',
      'sfx/robot_friend_beep.mp3',
      'Infinite_Menu.mp3',
      'Infinite_Spankage_M.mp3',
    ]);

    circuitBackground = CircuitBackground(this);
    await circuitBackground.load();
    platformHolder = PlatformHolder();
    await platformHolder.load();
    coinHolder = CoinHolder();
    coinHolder.setPersonalGameRef(this);
    await coinHolder.load();
    wireHolder = WireHolder();
    await wireHolder.load();
    bugHolder = BugHolder();
    await bugHolder.load();
    debrisHolder = DebrisHolder();
    await debrisHolder.load();
    wallHolder = WallHolder();
    await wallHolder.load();
    fireworks = Firework(this);
    await fireworks.load();

    gameState = GameState();

    runner = Runner();
    await runner.load();

    loaded = true;
    _distance = TextComponent("Time: 0",
        position: Vector2(size.x - 100, 10), textRenderer: scoresPaint)
      ..anchor = Anchor.topRight;
    _distance.changePriorityWithoutResorting(OVERLAY_PRIORITY);
    _coins = TextComponent(": 0",
        position: Vector2(size.x - 20, 10), textRenderer: scoresPaint)
      ..anchor = Anchor.topRight;
    _coins.changePriorityWithoutResorting(OVERLAY_PRIORITY);
    overlays.add("gameOver");
    overlays.remove('gameOver');
    overlays.add("mainMenu");
    overlays.add('loading');
    setUp();
    gameState.setPaused();
    startLoading = DateTime.now().microsecondsSinceEpoch;
  }

  void playMusic() {
    if (overlays.isActive('mainMenu')) {
      FlameAudio.bgm.play('Infinite_Menu.mp3');
    } else {
      FlameAudio.bgm.play('Infinite_Spankage_M.mp3');
    }
    playingMusic = true;
  }

  void fillScreen() {
    if (shouldReset) {
      return;
    }
    int dangerLevel = gameState.getDangerLevel();

    platformHolder.generatePlatforms(this);

    if (dangerLevel > 2) {
      int wireChosenRegion = random.nextInt(9);
      if (wireChosenRegion % 3 != 2 &&
          wireChosenRegion != 6 &&
          wireChosenRegion != 7) {
        wireHolder.generateWire(this, wireChosenRegion);
      }
    }

    if (dangerLevel > 0) {
      int bugChosenRegion = random.nextInt(9);
      if (bugChosenRegion % 3 != 2 && bugChosenRegion % 3 != 0) {
        bugHolder.generateBug(this, bugChosenRegion);
      }
    }

    if (dangerLevel > 1) {
      int debrisChosenRegion = random.nextInt(9);
      if (debrisChosenRegion % 3 == 0 && debrisChosenRegion != 6) {
        debrisHolder.generateDebris(this, debrisChosenRegion);
      }
    }

    int choseCoinLevel = random.nextInt(9);
    if (choseCoinLevel % 3 != 2 && choseCoinLevel != 6) {
      coinHolder.generateCoin(this, choseCoinLevel);
    }

    if (dangerLevel > 4) {
      int wallChosenRegion = random.nextInt(9);
      if (wallChosenRegion % 3 == 1 && wallChosenRegion != 7) {
        wallHolder.generateWall(this, wallChosenRegion);
      }
    }
  }

  bool isTooNearOtherObstacles(Rect rect) {
    Rect obstacleBounds = Rect.fromLTRB(
        3 * rect.left - 2 * (rect.left + blockSize) - 1,
        3 * rect.top - 2 * (rect.top + blockSize) - 1,
        3 * (rect.left + blockSize) - 2 * rect.left + 1,
        3 * (rect.top + blockSize) - 2 * rect.top + 1);
    for (List<MovingObject> wireLevel in wireHolder.objects) {
      for (MovingObject wire in wireLevel) {
        if (wire.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> coinLevel in coinHolder.objects) {
      for (MovingObject coin in coinLevel) {
        if (coin.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> bugLevel in bugHolder.objects) {
      for (MovingObject bug in bugLevel) {
        if (bug.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> debrisLevel in debrisHolder.objects) {
      for (MovingObject debris in debrisLevel) {
        if (debris.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    for (List<MovingObject> wallLevel in wallHolder.objects) {
      for (MovingObject wall in wallLevel) {
        if (wall.intersect(obstacleBounds) != "none") {
          return true;
        }
      }
    }

    return false;
  }

  bool shouldReset = false;

  // late Socket socket;
  // void dataHandler(data) {
  //   print(new String.fromCharCodes(data).trim());
  // }
  //
  // void errorHandler(error, StackTrace trace) {
  //   print(error);
  // }
  //
  // void doneHandler() {
  //   socket.destroy();
  // }

  // Future<void> connectServer() async {
  //   try {
  //     Socket.connect('10.0.0.224', 50018).then((Socket sock) {
  //       socket = sock;
  //       socket.listen(dataHandler,
  //           onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   // try {
  //   //   final response = await http.post(
  //   //     Uri.parse('http://10.0.0.224:50017'),
  //   //     headers: <String, String>{
  //   //       'Content-Type': 'application/json; charset=UTF-8',
  //   //     },
  //   //     body: jsonEncode(<String, String>{
  //   //       'title': "hi",
  //   //     }),
  //   //   );
  //   //   if (response.statusCode == 201) {
  //   //     // If the server did return a 201 CREATED response,
  //   //     // then parse the JSON.
  //   //     print("hello");
  //   //     print(response);
  //   //     print(response.body);
  //   //   } else {
  //   //     // If the server did not return a 201 CREATED response,
  //   //     // then throw an exception.
  //   //     throw Exception('Failed to create album.');
  //   //   }
  //   //   // var value = await channel.stream.first;
  //   //   // print(value);
  //   // } catch (e) {
  //   //   print(e);
  //   // }
  // }

  Future<void> displayLoss() async {
    if (!(runner.sprite.animation?.done() ?? false) &&
        runner.sprite.animation!.loop == false &&
        firstDeath) {
      return;
    }
    // await connectServer();
    firstDeath = false;
    overlays.add('gameOver');
  }

  void mainMenu() {
    overlays.remove('gameOver');
    overlays.add('mainMenu');
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('Infinite_Menu.mp3');
  }

  void reset() {
    runner.sprite.animation!.reset();
    overlays.remove('gameOver');
    overlays.remove('mainMenu');
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
    debrisHolder.setUp();
    wallHolder.setUp();

    gameState.setUp(this);

    runner.setUp();
    add(_coins);
    add(_distance);

    fillScreen();
    platformHolder.objects[2][0].sprite.current = PlatformState.left;
    platformHolder.objects[5][0].sprite.current = PlatformState.left;
  }

  @override
  void render(Canvas canvas) {
    if (!overlays.isActive('mainMenu')) {
      circuitBackground.render(canvas);
      fireworks.renderText(canvas);
      super.render(canvas);
      // final fpsCount = fps(10000);
      // fireworksPaint.render(
      //   canvas,
      //   fpsCount.toString(),
      //   Vector2(0, 0),
      // );
      coinHolder.renderCoinScore(canvas);
    }
  }

  @override
  void update(double dt) {
    if (overlays.isActive('loading') &&
        (DateTime.now().microsecondsSinceEpoch - startLoading) > LOADING_TIME) {
      overlays.remove('loading');
      if (!kIsWeb) {
        playMusic();
      }
    }
    fireworks.update(dt);
    platformHolder.removePast(this);
    coinHolder.removePast(this);
    wireHolder.removePast(this);
    bugHolder.removePast(this);
    debrisHolder.removePast(this);
    wallHolder.removePast(this);
    fillScreen();
    super.update(dt);
    circuitBackground.update(dt);
    gameState.update(dt);
    platformHolder.update(dt);
    coinHolder.update(dt);
    wireHolder.update(dt);
    bugHolder.update(dt);
    debrisHolder.update(dt);
    wallHolder.update(dt);

    _distance.text = "Time: ${gameState.getPlayerDistance()}";
    _coins.text = " ${gameState.numCoins}";
    if (shouldReset &&
        !overlays.isActive('gameOver') &&
        !overlays.isActive('mainMenu')) {
      displayLoss();
    }
  }

  @override
  void onResize(Vector2 canvasSize) {
    Vector2 oldSize = viewport.canvasSize;
    super.onResize(canvasSize);
    blockSize = canvasSize.y / 9;
    if (loaded) {
      double xRatio = canvasSize.x / oldSize.x;
      double yRatio = canvasSize.y / oldSize.y;
      circuitBackground.resize(canvasSize, xRatio, yRatio);
      runner.resize(canvasSize, xRatio, yRatio);
      platformHolder.resize(canvasSize, xRatio, yRatio);
      coinHolder.resize(canvasSize, xRatio, yRatio);
      wireHolder.resize(canvasSize, xRatio, yRatio);
      bugHolder.resize(canvasSize, xRatio, yRatio);
      debrisHolder.resize(canvasSize, xRatio, yRatio);
      wallHolder.resize(canvasSize, xRatio, yRatio);
      fireworks.resize(canvasSize, xRatio, yRatio);
    }
  }

  // Mobile controls
  late List<double> xDeltas;
  late List<double> yDeltas;
  @override
  void onPanStart(DragStartInfo info) {
    xDeltas = List.empty(growable: true);
    yDeltas = List.empty(growable: true);
  }

  bool action = false;

  @override
  void onPanUpdate(DragUpdateInfo info) {
    xDeltas.add(info.delta.game.x);
    yDeltas.add(info.delta.game.y);
    if (xDeltas.length > 2 && !action) {
      action = true;
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
      xDeltas = List.empty(growable: true);
      yDeltas = List.empty(growable: true);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    action = false;
    xDeltas = List.empty(growable: true);
    yDeltas = List.empty(growable: true);
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
    if (event is RawKeyDownEvent) {
      action = true;
      keyboardKey = null;
      switch (event.data.logicalKey.keyId) {
        case 4294968068:
        case 119:
        case 87:
          // case "w":
          runner.control("up");
          break;
        case 4294968066:
        case 97:
        case 65:
          // case "a":
          runner.control("left");
          break;
        case 4294968065:
        case 115:
        case 83:
          // case "s":
          runner.control("down");
          break;
        case 4294968067:
        case 100:
        case 68:
          // case "d":
          runner.control("right");
          break;
        default:
          break;
      }
    }

    if (event is RawKeyUpEvent) {
      action = false;
    }
  }
}
