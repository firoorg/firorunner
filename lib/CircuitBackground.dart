import 'package:firo_runner/MovingObject.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class CircuitBackground extends MovingObject {
  late var background;
  late Sprite background1;
  late Sprite background2;
  Vector2 background1Size = Vector2(0, 0);
  Vector2 background2Size = Vector2(0, 0);
  Vector2 background1Position = Vector2(0, 0);
  Vector2 background2Position = Vector2(0, 0);

  CircuitBackground(MyGame gameRef) : super(gameRef);

  Future load() async {
    background = await Flame.images.load("bg.png");
    background1 = Sprite(background);
    background2 = Sprite(background);

    background1Size = Vector2(
        gameRef.size.y * (background!.width / background!.height),
        gameRef.size.y);
    background2Size = Vector2(
        gameRef.size.y * (background!.width / background!.height),
        gameRef.size.y);
  }

  @override
  void update(double dt) {
    if (background1Position.x + background1Size.x < 0) {
      double newPosition = background2Position.x + background2Size.x;
      background1Position = Vector2(newPosition - 1, 0);
    } else if (background2Position.x + background2Size.x < 0) {
      double newPosition = background1Position.x + background1Size.x;
      background2Position = Vector2(newPosition - 1, 0);
    }

    double velocity = gameRef.gameState.getVelocity() / 10.0;
    background1Position = background1Position - Vector2(velocity * dt, 0);
    background2Position = background2Position - Vector2(velocity * dt, 0);
  }

  void render(Canvas canvas) {
    background1.render(canvas,
        size: background1Size, position: background1Position);
    background2.render(canvas,
        size: background2Size, position: background2Position);
  }
}
