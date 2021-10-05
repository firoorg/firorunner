import 'package:flame/extensions.dart';
import 'package:firo_runner/bug.dart';
import 'package:firo_runner/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';

enum RunnerState {
  run,
  jump,
  duck,
  duck2,
  duck3,
  kick,
  kick2,
  kick3,
  float,
  float2,
  float3,
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
  bool dead = false;
  late var boost = null;
  late var friend = null;

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
    getSprite().render(c,
        position: Vector2(sprite.position.x - sprite.size.x / 3,
            sprite.position.y - sprite.size.y / 3),
        size: sprite.size * 1.6);
  }

  void updateLevel() {
    level = (sprite.position.y / gameRef.blockSize).round();
  }

  Future<void> event(String event) async {
    if (gameRef.gameState.isPaused) {
      return;
    }
    sprite.animation!.reset();
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
          duration: 0.15,
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
        clearEffects();
        if (level - 1 < 0) {
          break;
        }
        runnerState = event;
        switch (gameRef.gameState.getRobotLevel()) {
          case 3:
            sprite.current = RunnerState.float3;
            break;
          case 2:
            sprite.current = RunnerState.float2;
            break;
          default:
            sprite.current = RunnerState.float;
            break;
        }
        sprite.addEffect(MoveEffect(
          path: [
            Vector2(sprite.x, (level - 2) * gameRef.blockSize),
          ],
          duration: 0.20,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            clearEffects();
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
        clearEffects();
        runnerState = event;
        sprite.current = RunnerState.fall;
        sprite.addEffect(getFallingEffect());
        break;
      case "kick":
        previousState = runnerState;
        runnerState = event;
        switch (gameRef.gameState.getRobotLevel()) {
          case 3:
            sprite.current = RunnerState.kick3;
            break;
          case 2:
            sprite.current = RunnerState.kick2;
            break;
          default:
            sprite.current = RunnerState.kick;
            break;
        }
        break;
      case "run":
        previousState = runnerState;
        runnerState = event;
        sprite.current = RunnerState.run;
        break;
      case "float":
        previousState = runnerState;
        runnerState = event;
        switch (gameRef.gameState.getRobotLevel()) {
          case 3:
            sprite.current = RunnerState.float3;
            break;
          case 2:
            sprite.current = RunnerState.float2;
            break;
          default:
            sprite.current = RunnerState.float;
            break;
        }
        boost = await FlameAudio.audioCache.play('sfx/jet_boost.mp3');
        sprite.addEffect(MoveEffect(
          path: [sprite.position],
          duration: 1.5,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            boost.stop();
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
        switch (gameRef.gameState.getRobotLevel()) {
          case 3:
            sprite.current = RunnerState.duck3;
            break;
          case 2:
            sprite.current = RunnerState.duck2;
            break;
          default:
            sprite.current = RunnerState.duck;
            break;
        }
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
        await FlameAudio.audioCache.play('sfx/fall_death.mp3');
        previousState = runnerState;
        clearEffects();
        runnerState = event;
        sprite.current = RunnerState.die;
        dead = true;
        friend.stop();
        gameRef.die();
        sprite.addEffect(getFallingEffect());
        break;
      case "electrocute":
        if (dead) {
          return;
        }
        await FlameAudio.audioCache.play('sfx/fall_death.mp3');
        previousState = runnerState;
        clearEffects();
        runnerState = event;
        sprite.current = RunnerState.electrocute;
        dead = true;
        friend.stop();
        gameRef.die();
        sprite.addEffect(getFallingEffect());
        break;
      case "glitch":
        if (dead) {
          return;
        }
        await FlameAudio.play('sfx/glitch_death.mp3');
        previousState = runnerState;
        clearEffects();
        runnerState = event;
        sprite.current = RunnerState.glitch;
        dead = true;
        friend.stop();
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
        if (runnerState == "run" || runnerState == "kick") {
          event("jump");
        } else if (runnerState == "float" && previousState == "jump") {
          event("double_jump");
        } else if (runnerState == "duck") {
          clearEffects();
          event("run");
        }
        break;
      case "down":
        if (runnerState == "run" || runnerState == "kick") {
          event("duck");
        } else if (runnerState == "float" && onTopOfPlatform()) {
          clearEffects();
          event("run");
        } else if (runnerState == "float") {
          clearEffects();
          event("fall");
        }
        break;
      case "right":
        if (runnerState == "run" || runnerState == "kick") {
          event("kick");
        }
        break;
      case "left":
        if (runnerState == "kick") {
          sprite.animation!.reset();
          clearEffects();
          event("run");
        }
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
      if (!dead) {
        sprite.animation!.reset();
        if (runnerState == "kick") {
          event("run");
        }
        sprite.current = RunnerState.run;
      }
    }

    if (runnerState == "float" || runnerState == "double_jump") {
      if (onTopOfPlatform()) {
        updateLevel();
        clearEffects();
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

  Future<void> intersecting() async {
    if (gameRef.gameState.isPaused) {
      return;
    }
    Rect runnerRect = sprite.toRect();
    bool onTopOfPlatform = this.onTopOfPlatform();

    for (List<MovingObject> coinLevel in gameRef.coinHolder.objects) {
      for (int i = 0; i < coinLevel.length;) {
        if (coinLevel[i].intersect(runnerRect) != "none") {
          gameRef.gameState.numCoins++;
          await FlameAudio.audioCache.play('sfx/coin_catch.mp3');
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
          Rect above = Rect.fromLTRB(
              runnerRect.left + sprite.width / 3,
              runnerRect.top - 1,
              runnerRect.right - sprite.width / 3,
              runnerRect.bottom);
          String aboveIntersect = bugLevel[i].intersect(above);
          if (aboveIntersect != "none" &&
              (runnerState == "duck" || runnerState == "float")) {
            continue;
          } else if (aboveIntersect != "none") {
            event("glitch");
            return;
          }
        } else if (intersectState == "left" && runnerState == "kick") {
          await FlameAudio.audioCache.play('sfx/bug_chomp.mp3');
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
          await FlameAudio.audioCache.play('sfx/obstacle_death.mp3');
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
          await FlameAudio.audioCache.play('sfx/obstacle_death.mp3');
          event("die");
        }
      }
    }

    if (!onTopOfPlatform &&
        (runnerState == "run" ||
            runnerState == "kick" ||
            runnerState == "duck")) {
      clearEffects();
      event("fall");
    }
  }

  Future load() async {
    List<Image> satellites = [];
    for (int i = 1; i <= 38; i++) {
      satellites.add(await Flame.images.load(
          'runner/satellite/satellite00${i < 10 ? "0" + i.toString() : i.toString()}.png'));
    }

    SpriteAnimation running =
        await loadSpriteAnimation("run", 38, satellites: satellites);

    SpriteAnimation jumping = await loadSpriteAnimation("jump", 6,
        satellites: satellites, loop: false);

    SpriteAnimation ducking =
        await loadSpriteAnimation("duck1", 38, satellites: satellites);

    SpriteAnimation ducking2 =
        await loadSpriteAnimation("duck2", 38, satellites: satellites);

    SpriteAnimation ducking3 =
        await loadSpriteAnimation("duck3", 38, satellites: satellites);

    SpriteAnimation kicking = await loadSpriteAnimation("attack1", 38,
        satellites: satellites, loop: false);

    SpriteAnimation kicking2 = await loadSpriteAnimation("attack2", 38,
        satellites: satellites, loop: false);

    SpriteAnimation kicking3 = await loadSpriteAnimation("attack3", 38,
        satellites: satellites, loop: false);

    SpriteAnimation floating =
        await loadSpriteAnimation("hover1", 44, satellites: satellites);

    SpriteAnimation floating2 =
        await loadSpriteAnimation("hover2", 44, satellites: satellites);

    SpriteAnimation floating3 =
        await loadSpriteAnimation("hover3", 44, satellites: satellites);

    SpriteAnimation falling = await loadSpriteAnimation("fall", 20,
        satellites: satellites, loop: false);

    SpriteAnimation dying =
        await loadSpriteAnimation("death2", 57, loop: false);

    SpriteAnimation dyingGlitch =
        await loadSpriteAnimation("death1", 81, loop: false);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        RunnerState.run: running,
        RunnerState.jump: jumping,
        RunnerState.duck: ducking,
        RunnerState.duck2: ducking2,
        RunnerState.duck3: ducking3,
        RunnerState.kick: kicking,
        RunnerState.kick2: kicking2,
        RunnerState.kick3: kicking3,
        RunnerState.float: floating,
        RunnerState.float2: floating2,
        RunnerState.float3: floating3,
        RunnerState.fall: falling,
        RunnerState.die: dying,
        RunnerState.electrocute: dying,
        RunnerState.glitch: dyingGlitch,
      },
      current: RunnerState.run,
    );

    changePriorityWithoutResorting(RUNNER_PRIORITY);
  }

  Future<SpriteAnimation> loadSpriteAnimation(String name, int howManyFrames,
      {List<Image>? satellites, bool loop = true}) async {
    List<Sprite> sprites = [];
    for (int i = 1; i <= howManyFrames; i++) {
      final composition = ImageComposition();
      if (satellites != null) {
        composition.add(
            satellites.elementAt(((i - 1) % satellites.length)), Vector2(0, 0));
      }
      composition.add(
          await Flame.images.load(
              'runner/$name/${name}00${i < 10 ? "0" + i.toString() : i.toString()}.png'),
          Vector2(0, 0));

      sprites.add(Sprite(await composition.compose()));
    }

    return SpriteAnimation.spriteList(sprites, stepTime: 0.02, loop: loop);
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

  void clearEffects({bool keepSounds = false}) {
    sprite.clearEffects();
    if (!keepSounds) {
      boost.stop();
    }
  }
}
