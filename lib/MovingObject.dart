import 'package:flutter/material.dart';

import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

class MovingObject extends Component {
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

  @override
  void render(Canvas c) {
    super.render(c);
  }

  @override
  void update(double dt) {
    super.update(dt);
    sprite.update(dt);
    double velocity = gameRef.gameState.getVelocity();
    sprite.position = sprite.position - Vector2(velocity * dt, 0);
  }

  @override
  void remove() {
    super.remove();
  }
}
