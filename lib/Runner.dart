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
}

class Runner extends Component with HasGameRef<MyGame> {
  late SpriteAnimationGroupComponent sprite;
  String runnerState = "run";

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

  int level = 1;

  void updateLevel() {
    level = (sprite.position.y / gameRef.blockSize).round();
  }

  String previousState = "run";

  void event(String event) {
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
          speed: 50,
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
        sprite.current = RunnerState.jump;
        sprite.addEffect(MoveEffect(
          path: [
            sprite.position,
            Vector2(sprite.x, (level - 2) * gameRef.blockSize),
          ],
          speed: 50,
          curve: Curves.ease,
          onComplete: () {
            updateLevel();
            runnerState = "run";
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
            if (runnerState == "fall") {
              updateLevel();
              sprite.position = Vector2(sprite.x, level * gameRef.blockSize);
              this.event("run");
            } else {
              this.event("float");
            }
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
          speed: 50,
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
        runnerState = event;
        sprite.current = RunnerState.die;
        break;
      case "electro":
        runnerState = event;
        sprite.current = RunnerState.electro;
        break;
      default:
        break;
    }
  }

  void control(String input) {
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
          // The runner has hit his head on the ceiling and should die.
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
        stepTime: 0.03,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation floating = await loadSpriteAnimation(
      'run-frames.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation falling = await loadSpriteAnimation(
      'run-frames.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
      ),
    );

    SpriteAnimation dieing = await loadSpriteAnimation(
      'death-normal-frames.png',
      SpriteAnimationData.sequenced(
        amount: 20,
        stepTime: 0.05,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );

    SpriteAnimation dieingElectorcuted = await loadSpriteAnimation(
      'electrecuted-frames.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(512, 512),
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
        RunnerState.die: dieing,
        RunnerState.electro: dieingElectorcuted,
      },
      current: RunnerState.run,
    );
  }
}
