import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum WireState { normal }

class Wire extends MovingObject {
  Wire(MyGame gameRef) : super(gameRef) {
    List<Sprite> wire = gameRef.wireHolder.getWire();
    SpriteAnimation normal = SpriteAnimation.spriteList(wire, stepTime: 0.05);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        WireState.normal: normal,
      },
      current: WireState.normal,
    );

    sprite.changePriorityWithoutResorting(WIRE_PRIORITY);

    setSize(
      gameRef.blockSize,
      gameRef.blockSize,
    );
  }

  // Override the intersect method so that the hitbox is smaller for the wires,
  // this will be more fair to the player.
  @override
  String intersect(Rect other) {
    Rect currentRect = sprite.toRect();
    Rect wireRect = Rect.fromLTWH(
      currentRect.left + 2 * currentRect.width / 5,
      currentRect.top + 2 * currentRect.height / 7,
      currentRect.width / 5,
      currentRect.height / 5,
    );
    final collision = wireRect.intersect(other);
    if (!collision.isEmpty) {
      double yDistance = other.top - wireRect.top;
      double xDistance = other.left - wireRect.left;
      if (yDistance.abs() > xDistance.abs()) {
        if (yDistance > 0) {
          return "bottom";
        } else {
          return "top";
        }
      } else {
        if (xDistance > 0) {
          return "right";
        } else {
          return "left";
        }
      }
    }
    return "none";
  }
}
