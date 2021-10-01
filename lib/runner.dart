import 'package:flame/extensions.dart';
import 'package:firo_runner/bug.dart';
import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/animation.dart';

enum RunnerState {
  run,
  jump,
  duck,
  kick,
  float,
  fall,
  die,
  electrocute,
  glitch,
}

class Runner extends Component with HasGameRef<MyGame> {
  late SpriteAnimationGroupComponent sprite;
  String runnerState = "run";
  int level = 4;
  String previousState = "run";
  var runnerPosition = Vector2(0, 0);
  late Vector2 runnerSize;
  // late Rect runnerRect;
  bool dead = false;

  void setUp() {
    dead = false;
    runnerState = "run";
    previousState = "run";
    level = 4;

    runnerSize = Vector2(
      gameRef.size.y / 9,
      gameRef.size.y / 9,
    );

    setSize(runnerSize, gameRef.blockSize);
    runnerPosition = Vector2(gameRef.blockSize * 2, gameRef.blockSize * 4);
    setPosition(runnerPosition);
  }

  void setPosition(Vector2 position) {
    sprite.position = position;
  }

  void setSize(Vector2 size, double ySize) {
    sprite.size = size;
  }

  Sprite getSprite() {
    return sprite.animation!.getSprite();
  }

  @override
  void render(Canvas c) {
    super.render(c);
    // getSprite().render(c, position: sprite.position, size: sprite.size);
    getSprite().render(c,
        position: Vector2(sprite.position.x - sprite.size.x / 3,
            sprite.position.y - sprite.size.y / 3),
        size: sprite.size * 1.6);
  }

  void updateLevel() {
    level = (sprite.position.y / gameRef.blockSize).round();
  }

  void event(String event) {
    if (gameRef.gameState.isPaused) {
      return;
    }
    switch (event) {
      case "jump":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.jump;
        sprite.addEffect(MoveEffect(
          path: [
            // sprite.position,
            Vector2(sprite.x, (level - 1) * gameRef.blockSize),
          ],
          duration: 0.25,
          curve: Curves.bounceIn,
          onComplete: () {
            updateLevel();
            this.event("float");
          },
        ));
        break;
      case "double_jump":
        if (belowPlatform()) {
          break;
        }
        previousState = runnerState;
        sprite.clearEffects();
        if (level - 1 < 0) {
          break;
        }
        runnerState = event;
        sprite.current = RunnerState.float;
        sprite.addEffect(MoveEffect(
          path: [
            Vector2(sprite.x, (level - 2) * gameRef.blockSize),
          ],
          duration: 0.5,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            if (onTopOfPlatform()) {
              this.event("run");
            } else {
              this.event("float");
            }
          },
        ));
        break;
      case "fall":
        previousState = runnerState;
        sprite.clearEffects();
        runnerState = event;
        sprite.current = RunnerState.fall;
        sprite.addEffect(getFallingEffect());
        break;
      case "kick":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.kick;
        break;
      case "run":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.run;
        break;
      case "float":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.float;
        sprite.addEffect(MoveEffect(
          path: [sprite.position],
          duration: 1.5,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            if (onTopOfPlatform()) {
              this.event("run");
            } else {
              this.event("fall");
            }
          },
        ));
        break;
      case "duck":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.duck;
        sprite.addEffect(MoveEffect(
          path: [sprite.position],
          duration: 1.5,
          curve: Curves.linear,
          onComplete: () {
            this.event("run");
          },
        ));
        break;
      case "die":
        if (dead) {
          return;
        }
        previousState = runnerState;
        sprite.clearEffects();
        level = 11;
        sprite.addEffect(MoveEffect(
          path: [Vector2(sprite.position.x, gameRef.blockSize * 11)],
          duration: 2,
          curve: Curves.bounceOut,
          onComplete: () {},
        ));
        runnerState = event;
        sprite.current = RunnerState.die;
        gameRef.die();
        break;
      case "electrocute":
        if (dead) {
          return;
        }
        previousState = runnerState;
        sprite.clearEffects();
        level = 11;
        sprite.addEffect(MoveEffect(
          path: [Vector2(sprite.position.x, gameRef.blockSize * 11)],
          duration: 1,
          curve: Curves.bounceOut,
          onComplete: () {},
        ));
        runnerState = event;
        sprite.current = RunnerState.electrocute;
        gameRef.die();
        break;
      case "glitch":
        if (dead) {
          return;
        }
        previousState = runnerState;
        sprite.clearEffects();
        level = 11;
        sprite.addEffect(MoveEffect(
          path: [Vector2(sprite.position.x, gameRef.blockSize * 11)],
          duration: 1,
          curve: Curves.bounceOut,
          onComplete: () {},
        ));
        runnerState = event;
        sprite.current = RunnerState.glitch;
        gameRef.die();
        break;
      default:
        break;
    }
  }

  MoveEffect getFallingEffect() {
    for (int i = level; i < 9; i++) {
      if (i % 3 != 2) {
        continue;
      }
      int distance = (i - 1 - level);
      double time = 0.2;
      for (int x = 2; x < distance; x++) {
        time += time * pow(0.5, x - 1);
      }
      double estimatedXCoordinate =
          time * gameRef.gameState.getVelocity() + sprite.x;
      for (MovingObject p in gameRef.platformHolder.objects[i]) {
        if (estimatedXCoordinate >= p.sprite.x - p.sprite.width / 2 &&
            estimatedXCoordinate <= p.sprite.x + p.sprite.width) {
          return MoveEffect(
            path: [
              Vector2(sprite.x, (i - 1) * gameRef.blockSize),
            ],
            duration: time,
            curve: Curves.ease,
            onComplete: () {
              updateLevel();
              if (onTopOfPlatform()) {
                event("run");
              } else {
                event("fall");
              }
            },
          );
        }
      }
    }
    return MoveEffect(
      path: [
        Vector2(sprite.x, 8 * gameRef.blockSize),
      ],
      duration: 0.2 * (8 - level),
      curve: Curves.ease,
      onComplete: () {
        updateLevel();
        if (onTopOfPlatform()) {
          event("run");
        } else {
          event("fall");
        }
      },
    );
  }

  void control(String input) {
    if (gameRef.gameState.isPaused) {
      return;
    }
    switch (input) {
      case "up":
        if (runnerState == "run") {
          event("jump");
        } else if (runnerState == "float" && previousState == "jump") {
          event("double_jump");
        } else if (runnerState == "duck") {
          sprite.clearEffects();
          event("run");
        }
        break;
      case "down":
        if (runnerState == "run") {
          event("duck");
        } else if (runnerState == "float" && onTopOfPlatform()) {
          sprite.clearEffects();
          event("run");
        } else if (runnerState == "float") {
          sprite.clearEffects();
          event("fall");
        }
        break;
      case "right":
        if (runnerState == "run") {
          event("kick");
        }
        break;
      case "left":
        if (runnerState == "kick") {
          sprite.animation!.reset();
          sprite.clearEffects();
          event("run");
        }
        break;
      case "center":
        // if (runnerState == "fall") {
        //   updateLevel();
        //   event("float");
        // }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (sprite.position.y + sprite.size.y >= gameRef.size.y) {
      event("die");
    }
    // If the animation is finished
    if (sprite.animation?.done() ?? false) {
      sprite.animation!.reset();
      if (runnerState == "kick") {
        event("run");
      }
      sprite.current = RunnerState.run;
    }

    if (runnerState == "float" || runnerState == "double_jump") {
      if (onTopOfPlatform()) {
        updateLevel();
        sprite.clearEffects();
        event("run");
      }
    }

    intersecting();
    sprite.update(dt);
  }

  bool onTopOfPlatform() {
    Rect runnerRect = sprite.toRect();
    bool onTopOfPlatform = false;
    for (List<MovingObject> platformLevel in gameRef.platformHolder.objects) {
      for (MovingObject p in platformLevel) {
        String side = p.intersect(runnerRect);
        if (side == "none") {
          Rect belowRunner = Rect.fromLTRB(runnerRect.left, runnerRect.top,
              runnerRect.right, runnerRect.bottom + 1);
          if (p.intersect(belowRunner) != "none") {
            onTopOfPlatform = true;
          }
        }
      }
    }
    return onTopOfPlatform;
  }

  bool belowPlatform() {
    Rect runnerRect = Rect.fromLTRB(
        sprite.toRect().left,
        sprite.toRect().top,
        sprite.toRect().right - sprite.toRect().width / 2,
        sprite.toRect().bottom);
    bool belowPlatform = false;
    for (List<MovingObject> platformLevel in gameRef.platformHolder.objects) {
      for (MovingObject p in platformLevel) {
        String side = p.intersect(runnerRect);
        if (side == "none") {
          Rect belowRunner = Rect.fromLTRB(runnerRect.left, runnerRect.top - 1,
              runnerRect.right, runnerRect.bottom);
          if (p.intersect(belowRunner) == "bottom") {
            belowPlatform = true;
          }
        }
      }
    }
    return belowPlatform;
  }

  void intersecting() {
    if (gameRef.gameState.isPaused) {
      return;
    }
    Rect runnerRect = sprite.toRect();
    bool onTopOfPlatform = this.onTopOfPlatform();

    for (List<MovingObject> coinLevel in gameRef.coinHolder.objects) {
      for (int i = 0; i < coinLevel.length;) {
        if (coinLevel[i].intersect(runnerRect) != "none") {
          gameRef.gameState.numCoins++;
          gameRef.coinHolder.remove(coinLevel, i);
          continue;
        }
        i++;
      }
    }

    for (List<MovingObject> wireLevel in gameRef.wireHolder.objects) {
      for (int i = 0; i < wireLevel.length; i++) {
        if (wireLevel[i].intersect(runnerRect) != "none") {
          event("electrocute");
          return;
        }
      }
    }

    for (List<MovingObject> bugLevel in gameRef.bugHolder.objects) {
      for (int i = 0; i < bugLevel.length; i++) {
        String intersectState = bugLevel[i].intersect(runnerRect);
        if (bugLevel[i].sprite.current == BugState.breaking) {
          continue;
        }
        if (intersectState == "none") {
          Rect above = Rect.fromLTRB(runnerRect.left, runnerRect.top - 1,
              runnerRect.right, runnerRect.bottom);
          String aboveIntersect = bugLevel[i].intersect(above);
          if (aboveIntersect != "none" &&
              (runnerState == "duck" || runnerState == "float")) {
            continue;
          } else if (aboveIntersect != "none") {
            event("glitch");
            return;
          }
        } else if (intersectState == "left" && runnerState == "kick") {
          bugLevel[i].sprite.current = BugState.breaking;
          gameRef.coinHolder.generateCoin(gameRef, level,
              force: true, xPosition: bugLevel[i].sprite.x + gameRef.blockSize);
        } else {
          event("glitch");
          return;
        }
      }
    }

    for (List<MovingObject> debrisLevel in gameRef.debrisHolder.objects) {
      for (int i = 0; i < debrisLevel.length; i++) {
        Rect slim = Rect.fromLTRB(
            runnerRect.left + sprite.width / 3,
            runnerRect.top,
            runnerRect.right - sprite.width / 3,
            runnerRect.bottom);
        String intersectState = debrisLevel[i].intersect(slim);
        if (intersectState == "none") {
          continue;
        } else if (runnerState == "duck" && intersectState != "above") {
          continue;
        } else {
          event("die");
        }
      }
    }

    for (List<MovingObject> wallLevel in gameRef.wallHolder.objects) {
      for (int i = 0; i < wallLevel.length; i++) {
        Rect slim = Rect.fromLTRB(
            runnerRect.left + sprite.width / 3,
            runnerRect.top + sprite.height / (runnerState == "duck" ? 3 : 6),
            runnerRect.right - sprite.width / 3,
            runnerRect.bottom - sprite.height / 3);
        String intersectState = wallLevel[i].intersect(slim);
        if (intersectState == "none") {
          continue;
        } else {
          event("die");
        }
      }
    }

    if (!onTopOfPlatform &&
        (runnerState == "run" ||
            runnerState == "kick" ||
            runnerState == "duck")) {
      event("fall");
    }
  }

  Future load(loadSpriteAnimation) async {
    List<Image> satellites = [];
    for (int i = 1; i <= 38; i++) {
      satellites.add(await Flame.images.load(
          'runner/satellite/satellite00${i < 10 ? "0" + i.toString() : i.toString()}.png'));
    }

    List<Sprite> runs = [];
    for (int i = 1; i <= 38; i++) {
      final composition = ImageComposition()
        ..add(satellites.elementAt(i - 1), Vector2(0, 0))
        ..add(
            await Flame.images.load(
                'runner/run/run00${i < 10 ? "0" + i.toString() : i.toString()}.png'),
            Vector2(0, 0));

      runs.add(Sprite(await composition.compose()));
    }

    SpriteAnimation running =
        SpriteAnimation.spriteList(runs, stepTime: 0.02, loop: true);

    List<Sprite> jumps = [];
    for (int i = 1; i <= 6; i++) {
      final composition = ImageComposition()
        ..add(satellites.elementAt(i - 1), Vector2(0, 0))
        ..add(
            await Flame.images.load(
                'runner/jump/jump00${i < 10 ? "0" + i.toString() : i.toString()}.png'),
            Vector2(0, 0));

      jumps.add(Sprite(await composition.compose()));
    }

    SpriteAnimation jumping =
        SpriteAnimation.spriteList(jumps, stepTime: 0.02, loop: false);

    List<Sprite> ducks = [];
    for (int i = 1; i <= 38; i++) {
      final composition = ImageComposition()
        ..add(satellites.elementAt(i - 1), Vector2(0, 0))
        ..add(
            await Flame.images.load(
                'runner/duck1/duck100${i < 10 ? "0" + i.toString() : i.toString()}.png'),
            Vector2(0, 0));

      ducks.add(Sprite(await composition.compose()));
    }

    SpriteAnimation ducking =
        SpriteAnimation.spriteList(ducks, stepTime: 0.02, loop: true);

    List<Sprite> kicks = [];
    for (int i = 1; i <= 38; i++) {
      final composition = ImageComposition()
        ..add(satellites.elementAt(i - 1), Vector2(0, 0))
        ..add(
            await Flame.images.load(
                'runner/attack1/attack100${i < 10 ? "0" + i.toString() : i.toString()}.png'),
            Vector2(0, 0));

      kicks.add(Sprite(await composition.compose()));
    }

    SpriteAnimation kicking =
        SpriteAnimation.spriteList(kicks, stepTime: 0.02, loop: false);

    List<Sprite> floats = [];
    for (int i = 1; i <= 44; i++) {
      final composition = ImageComposition()
        ..add(satellites.elementAt(((i - 1) % 38)), Vector2(0, 0))
        ..add(
            await Flame.images.load(
                'runner/hover1/hover100${i < 10 ? "0" + i.toString() : i.toString()}.png'),
            Vector2(0, 0));

      floats.add(Sprite(await composition.compose()));
    }

    SpriteAnimation floating =
        SpriteAnimation.spriteList(floats, stepTime: 0.02, loop: true);

    // TODO Falling animations
    // List<Sprite> falls = [];
    // for (int i = 1; i <= 38; i++) {
    //   falls.add(Sprite(await Flame.images.load(
    //       'runner/run/run00${i < 10 ? "0" + i.toString() : i.toString()}.png')));
    // }
    //
    // SpriteAnimation falling =
    //     SpriteAnimation.spriteList(falls, stepTime: 0.02, loop: true);

    SpriteAnimation falling = await loadSpriteAnimation(
      'fall-frames.png',
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    List<Sprite> dies = [];
    for (int i = 1; i <= 57; i++) {
      dies.add(Sprite(await Flame.images.load(
          'runner/death/death200${i < 10 ? "0" + i.toString() : i.toString()}.png')));
    }

    SpriteAnimation dying =
        SpriteAnimation.spriteList(dies, stepTime: 0.02, loop: false);

    List<Sprite> dyingGlitches = [];
    for (int i = 1; i <= 81; i++) {
      dyingGlitches.add(Sprite(await Flame.images.load(
          'runner/deathglitch/death100${i < 10 ? "0" + i.toString() : i.toString()}.png')));
    }

    SpriteAnimation dyingGlitch =
        SpriteAnimation.spriteList(dyingGlitches, stepTime: 0.02, loop: false);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        RunnerState.run: running,
        RunnerState.jump: jumping,
        RunnerState.duck: ducking,
        RunnerState.kick: kicking,
        RunnerState.float: floating,
        RunnerState.fall: falling,
        RunnerState.die: dying,
        RunnerState.electrocute: dying,
        RunnerState.glitch: dyingGlitch,
      },
      current: RunnerState.run,
    );

    changePriorityWithoutResorting(RUNNER_PRIORITY);
  }

  void resize(Vector2 newSize, double xRatio, double yRatio) {
    sprite.x = gameRef.blockSize * 2;
    sprite.y = gameRef.blockSize * level;
    sprite.size.x = gameRef.blockSize;
    sprite.size.y = gameRef.blockSize;
    if (sprite.effects.isNotEmpty) {
      sprite.effects.first.onComplete!();
    }
  }
}
