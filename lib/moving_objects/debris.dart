import 'package:firo_runner/biome.dart';
import 'package:firo_runner/biome_tinted_component.dart';
import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum DebrisState { normal }

class Debris extends MovingObject {
  Debris(MyGame gameRef) : super(gameRef) {
    List<Sprite> debris = gameRef.debrisHolder.getDebris();
    SpriteAnimation normal = SpriteAnimation.spriteList(debris, stepTime: 0.1);

    sprite = BiomeTintedSpriteAnimationGroupComponent<DebrisState>(
      animations: {
        DebrisState.normal: normal,
      },
      current: DebrisState.normal,
    );

    sprite.changePriorityWithoutResorting(DEBRIS_PRIORITY);

    setSize(
      gameRef.blockSize *
          (gameRef.debrisHolder.debris[0].image.width /
              gameRef.debrisHolder.debris[0].image.height) *
          1.5,
      gameRef.blockSize * 1.5,
    );
  }

  @override
  Color getTintColorForObject(BiomeConfig config) {
    return config.debrisTint;
  }
}
