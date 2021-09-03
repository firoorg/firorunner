import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameState extends Component {
  int numCoins = 0;
  int distance = 0;
  late Rect square;
  late Color color = Colors.white;
  int start = 0;
  late ColorTween tween;
  static const int CIRCUIT_PERIOD = 500000;

  @override
  void update(double dt) {
    super.update(dt);
    distance = DateTime.now().microsecondsSinceEpoch - start;
    color = tween.lerp(sin(distance.toDouble() / CIRCUIT_PERIOD))!;
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
    reset();
  }

  void setSize(Vector2 size) {
    square = Rect.fromLTWH(0, 0, size.x, size.y);
  }

  void reset() {
    start = DateTime.now().microsecondsSinceEpoch;
    tween = ColorTween(begin: Colors.yellow, end: Colors.yellowAccent);
  }

  double getVelocity() {
    if (distance > 50000000) {
      return 250.0;
    } else if (distance > 10000000)
      return 175.0;
    else {
      return 100.0;
    }
  }
}
