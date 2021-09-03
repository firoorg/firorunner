import 'package:firo_runner/main.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

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

  void setPosition(Vector2 position) {
    sprite.position = position;
  }

  void setSize(Vector2 size, double ySize) {
    // runnerSize = size;
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

  int level = 7;

  void updateLevel() {
    level = (sprite.position.y / gameRef.blockSize).round();
  }

  String runnerState = "run";

  void event(String event) {
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
            runnerState = "run";
          },
        ));
        break;
      case "doublejump":
        runnerState = event;
        sprite.current = RunnerState.jump;
        sprite.addEffect(MoveEffect(
          path: [
            sprite.position,
            Vector2(sprite.x, (level - 3) * gameRef.blockSize),
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
        // TODO calculate distance to next platform.
        sprite.addEffect(MoveEffect(
          path: [
            // sprite.position,
            Vector2(sprite.x, (level + 1) * gameRef.blockSize),
          ],
          speed: 50,
          curve: Curves.ease,
          onComplete: updateLevel,
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
          path: [
            sprite.position,
            Vector2(sprite.x, (level - 1) * gameRef.blockSize),
          ],
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
    print(runnerState + " " + input);
    print(sprite.position);
    switch (input) {
      case "up":
        if (runnerState == "run") {
          event("jump");
        } else if (runnerState == "jump") {
          event("doublejump");
        } else if (runnerState == "duck") {
          event("run");
        }
        break;
      case "down":
        if (runnerState == "run") {
          event("duck");
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
        if (runnerState == "jump") {
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

    sprite.update(dt);
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
