import 'package:flutter/material.dart';

import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

// Class meant to be extended by any object that will move left on the screen.
// Ensures a relatively constant moving velocity, and takes care of sprite
// animations and positioning.
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

  // Get the rightmost pixel position of this sprite.
  double getRightEnd() {
    return sprite.position.x + sprite.width;
  }

  void remove() {
    sprite.remove();
  }

  // See where this object intersects another object if at all.
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

  // Resize the object for chaning screen sizes.
  void resize(Vector2 newSize, double xRatio, double yRatio) {
    sprite.x *= xRatio;
    sprite.y *= yRatio;
    sprite.width *= xRatio;
    sprite.height *= yRatio;
  }
}
