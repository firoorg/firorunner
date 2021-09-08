import 'package:firo_runner/Bug.dart';
import 'package:firo_runner/Coin.dart';
import 'package:firo_runner/Wire.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'Platform.dart';

import 'package:flame/components.dart';

enum RunnerState {
  run,
  jump,
  duck,
  kick,
  float,
  fall,
  die,
  electro,
  glitch,
}

class Runner extends Component with HasGameRef<MyGame> {
  late SpriteAnimationGroupComponent sprite;
  String runnerState = "run";
  int level = 4;
  String previousState = "run";
  var runnerPosition = Vector2(0, 0);
  var runnerSize;
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
    getSprite().render(c, position: sprite.position, size: sprite.size);
  }

  void updateLevel() {
    level = (sprite.position.y / gameRef.blockSize).round();
  }

  void event(String event) {
    if (gameRef.gameState.isPaused) {
      return;
    }
    previousState = runnerState;
    print(event);
    switch (event) {
      case "jump":
        runnerState = event;
        sprite.current = RunnerState.jump;
        sprite.addEffect(MoveEffect(
          path: [
            // sprite.position,
            Vector2(sprite.x, (level - 1) * gameRef.blockSize),
          ],
          speed: 150,
          curve: Curves.bounceIn,
          onComplete: () {
            updateLevel();
            this.event("float");
          },
        ));
        break;
      case "doublejump":
        if (level - 1 < 0) {
          break;
        }
        runnerState = event;
        sprite.current = RunnerState.float;
        sprite.addEffect(MoveEffect(
          path: [
            Vector2(sprite.x, (level - 2) * gameRef.blockSize),
          ],
          speed: 150,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            this.event("float");
          },
        ));
        break;
      case "fall":
        runnerState = event;
        sprite.current = RunnerState.fall;
        sprite.addEffect(MoveEffect(
          path: [
            Vector2(sprite.x, (level + 1) * gameRef.blockSize),
          ],
          speed: 100,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            this.event("float");
          },
        ));
        break;
      case "kick":
        runnerState = event;
        sprite.current = RunnerState.kick;
        break;
      case "run":
        runnerState = event;
        sprite.current = RunnerState.run;
        break;
      case "float":
        runnerState = event;
        sprite.current = RunnerState.float;
        sprite.addEffect(MoveEffect(
          path: [sprite.position],
          speed: 500,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            runnerState = event;
            sprite.current = RunnerState.float;
          },
        ));
        break;
      case "duck":
        runnerState = event;
        sprite.current = RunnerState.duck;
        break;
      case "die":
        if (dead) {
          return;
        }
        runnerState = event;
        sprite.current = RunnerState.die;
        gameRef.die();
        break;
      case "electro":
        if (dead) {
          return;
        }
        runnerState = event;
        sprite.current = RunnerState.electro;
        gameRef.die();
        break;
      case "glitch":
        if (dead) {
          return;
        }
        runnerState = event;
        sprite.current = RunnerState.glitch;
        gameRef.die();
        break;
      default:
        break;
    }
  }

  void control(String input) {
    if (gameRef.gameState.isPaused) {
      return;
    }
    print(input);
    switch (input) {
      case "up":
        if (runnerState == "run") {
          event("jump");
        } else if (runnerState == "float" && previousState == "jump") {
          event("doublejump");
        } else if (runnerState == "duck") {
          event("run");
        }
        break;
      case "down":
        if (runnerState == "run") {
          event("duck");
        } else if (runnerState == "float" && onTopOfPlatform()) {
          event("run");
        } else if (runnerState == "float") {
          event("fall");
        }
        break;
      case "right":
        if (runnerState == "run") {
          event("kick");
        }
        break;
      case "center":
        if (runnerState == "fall") {
          updateLevel();
          event("float");
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // If the animation is finished
    if (sprite.animation?.done() ?? false) {
      sprite.animation!.reset();
      if (runnerState == "kick") {
        event("run");
      }
      sprite.current = RunnerState.run;
    }

    intersecting();
    sprite.update(dt);
  }

  bool onTopOfPlatform() {
    Rect runnerRect = sprite.toRect();
    bool onTopOfPlatform = false;
    for (List<Platform> platformLevel in gameRef.platformHolder.platforms) {
      for (Platform p in platformLevel) {
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

  void intersecting() {
    if (gameRef.gameState.isPaused) {
      return;
    }
    Rect runnerRect = sprite.toRect();
    bool onTopOfPlatform = false;
    for (List<Platform> platformLevel in gameRef.platformHolder.platforms) {
      for (Platform p in platformLevel) {
        String side = p.intersect(runnerRect);
        if (side == "none") {
          Rect belowRunner = Rect.fromLTRB(runnerRect.left, runnerRect.top,
              runnerRect.right, runnerRect.bottom + 1);
          if (p.intersect(belowRunner) != "none") {
            onTopOfPlatform = true;
          }
        } else if (side == "bottom") {
          event("die");
          return;
        }
      }
    }

    for (List<Coin> coinLevel in gameRef.coinHolder.coins) {
      for (int i = 0; i < coinLevel.length;) {
        if (coinLevel[i].intersect(runnerRect) != "none") {
          gameRef.gameState.numCoins++;
          gameRef.coinHolder.remove(coinLevel, i);
          print(gameRef.gameState.numCoins);
          continue;
        }
        i++;
      }
    }

    for (List<Wire> wireLevel in gameRef.wireHolder.wires) {
      for (int i = 0; i < wireLevel.length; i++) {
        if (wireLevel[i].intersect(runnerRect) != "none") {
          event("electro");
          return;
        }
      }
    }

    for (List<Bug> bugLevel in gameRef.bugHolder.bugs) {
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
          // bugLevel[i].remove();
          // bugLevel.removeAt(i);
        } else {
          event("glitch");
          return;
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
    SpriteAnimation running = await loadSpriteAnimation(
      'run-frames.png',
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation jumping = await loadSpriteAnimation(
      'jump-frames.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation ducking = await loadSpriteAnimation(
      'crawl-frames.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation kicking = await loadSpriteAnimation(
      'kick-frames.png',
      SpriteAnimationData.sequenced(
        amount: 13,
        stepTime: 0.05,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation floating = await loadSpriteAnimation(
      'hover-frames.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation falling = await loadSpriteAnimation(
      'hover-frames.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation dying = await loadSpriteAnimation(
      'death-normal-frames.png',
      SpriteAnimationData.sequenced(
        amount: 20,
        stepTime: 0.05,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation dyingElectrocuted = await loadSpriteAnimation(
      'electrocuted-frames.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.25,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation dyingGlitch = await loadSpriteAnimation(
      'death-glitched-frames.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    sprite = SpriteAnimationGroupComponent(
      animations: {
        RunnerState.run: running,
        RunnerState.jump: jumping,
        RunnerState.duck: ducking,
        RunnerState.kick: kicking,
        RunnerState.float: floating,
        RunnerState.fall: falling,
        RunnerState.die: dying,
        RunnerState.electro: dyingElectrocuted,
        RunnerState.glitch: dyingGlitch,
      },
      current: RunnerState.run,
    );

    changePriorityWithoutResorting(RUNNER_PRIORITY);
  }
}
