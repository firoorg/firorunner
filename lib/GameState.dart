import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameState extends Component {
  static const int CIRCUIT_PERIOD = 500000;
  late Rect square;
  late Color color = Colors.white;
  late ColorTween tween;

  int start = 0;
  bool isPaused = false;
  int numCoins = 0;
  int distance = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      distance = DateTime.now().microsecondsSinceEpoch - start;
      color = tween.lerp(sin(distance.toDouble() / CIRCUIT_PERIOD))!;
    }
  }

  void addCoin() {
    numCoins++;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(square, Paint()..color = color);
  }

  Future load(Vector2 size) async {
    square = Rect.fromLTWH(0, 0, size.x, size.y);
  }

  void setSize(Vector2 size) {
    square = Rect.fromLTWH(0, 0, size.x, size.y);
  }

  void setUp() {
    numCoins = 0;
    distance = 0;
    start = DateTime.now().microsecondsSinceEpoch;
    tween = ColorTween(begin: Colors.yellow, end: Colors.yellowAccent);
    isPaused = false;
  }

  void setPaused() {
    isPaused = true;
  }

  double getVelocity() {
    if (!isPaused) {
      if (distance > 50000000) {
        return 250.0;
      } else if (distance > 10000000)
        return 175.0;
      else {
        return 100.0;
      }
    } else {
      return 0;
    }
  }
}
