import 'package:flutter/material.dart';

import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

class MovingObject {
  late SpriteAnimationGroupComponent sprite;
  MyGame gameRef;

  MovingObject(this.gameRef);

  void setPosition(double x, double y) {
    sprite.position = Vector2(x, y);
  }

  void setSize(double x, double y) {
    sprite.size = Vector2(x, y);
  }

  Sprite getSprite() {
    return sprite.animation!.getSprite();
  }

  void update(double dt) {
    double velocity = gameRef.gameState.getVelocity();
    sprite.position = sprite.position - Vector2(velocity * dt, 0);
  }

  String intersect(Rect other) {
    final collision = sprite.toRect().intersect(other);
    if (!collision.isEmpty) {
      double yDistance = other.top - sprite.toRect().top;
      double xDistance = other.left - sprite.toRect().left;
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
