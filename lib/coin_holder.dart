import 'dart:math';

import 'package:flame/flame.dart';

import 'package:firo_runner/coin.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';

class CoinHolder {
  late Image coin;
  Random random = Random();

  late List<List<Coin>> coins = [];

  Future loadCoins() async {
    coin = await Flame.images.load("coin-frames.png");
  }

  void setUp() {
    for (int i = 0; i < coins.length; i++) {
      for (int j = 0; j < coins[i].length; j++) {
        remove(coins[i], j);
      }
    }
    coins = [];
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

  void remove(List<Coin> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder[j].sprite.remove();
    levelHolder.removeAt(j);
  }

  void removePast(MyGame gameRef) {
    for (List<Coin> coinLevel in coins) {
      for (int i = 0; i < coinLevel.length;) {
        if (coinLevel[i].sprite.x + coinLevel[i].sprite.width < 0) {
          remove(coinLevel, i);
          continue;
        }
        i++;
      }
    }
  }
}
