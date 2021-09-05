import 'dart:math';

import 'package:flame/flame.dart';

import 'Coin.dart';
import 'main.dart';

class CoinHolder {
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
    double xCoordinate = gameRef.platformHolder.getFlushX();
    xCoordinate = xCoordinate +
        gameRef.blockSize * random.nextInt(5) +
        gameRef.blockSize * 20;

    if (xCoordinate < gameRef.size.x || random.nextInt(100) > 25) {
      return true;
    } else {
      Coin coin = Coin(gameRef);
      coin.setPosition(xCoordinate, gameRef.blockSize * level);

      if (gameRef.isTooNearOtherObstacles(coin.sprite.toRect())) {
        return false;
      }

      coins[level].add(coin);
      gameRef.add(coin.sprite);
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
          coinLevel[i].sprite.remove();
          coinLevel.removeAt(i);
          continue;
        }
        i++;
      }
    }
  }
}
