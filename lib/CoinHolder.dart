import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'Coin.dart';
import 'main.dart';

class Coinholder {
  var coin;
  Random random = Random();

  late List<List<Coin>> coins = [];

  Future loadCoins() async {
    coin = await Flame.images.load("coin-frames.png");
    for (int i = 0; i < 9; i++) {
      coins.add([]);
    }
  }

  getCoin() {
    return coin;
  }

  bool generateCoin(MyGame gameRef, int level, bool force) {
    if (totalCoins() > 5) {
      return false;
    }
    double xCordinate = gameRef.platformHolder.getFlushX();
    // if (coins[level].isNotEmpty) {
    //   xCordinate = coins[level].last.getRightEnd();
    // }
    xCordinate = xCordinate +
        gameRef.blockSize * random.nextInt(5) +
        gameRef.blockSize * 20;

    if (xCordinate < gameRef.size.x && random.nextInt(1000000) > 99999) {
      return true;
    } else {
      Coin coin = Coin(gameRef);
      coin.setPosition(xCordinate, gameRef.blockSize * level);
      coins[level].add(coin);
      return false;
    }
  }

  int totalCoins() {
    int total = 0;
    for (List<Coin> levelCoins in coins) {
      total += levelCoins.length;
    }
    return total;
  }

  void render(Canvas canvas) {
    for (List<Coin> coinLevel in coins) {
      for (Coin p in coinLevel) {
        p.render(canvas);
      }
    }
  }

  void update(double dt) {
    for (List<Coin> coinLevel in coins) {
      for (Coin p in coinLevel) {
        p.update(dt);
      }
    }
  }

  void removePast(MyGame gameRef) {
    for (List<Coin> coinLevel in coins) {
      for (int i = 0; i < coinLevel.length;) {
        if (coinLevel[i].sprite.x + coinLevel[i].sprite.width < 0) {
          coinLevel.removeAt(i);
          continue;
        }
        i++;
      }
    }
  }
}
