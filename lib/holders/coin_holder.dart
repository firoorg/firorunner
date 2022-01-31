import 'package:firo_runner/holders/holder.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/coin.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/extensions.dart';
import 'package:firo_runner/moving_objects/platform.dart';

import '../course.dart';

class CoinHolder extends Holder {
  late List<Sprite> coin;
  late SpriteAnimationGroupComponent sprite;
  late MyGame personalGameRef;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    coin = await loadListSprites("coin", "coin", 12,
        sheets: 1, frameSize: Vector2(512, 512));
    SpriteAnimation normal = SpriteAnimation.spriteList(coin, stepTime: 0.1);

    sprite = SpriteAnimationGroupComponent(
      animations: {
        CoinState.normal: normal,
      },
      current: CoinState.normal,
    );

    sprite.changePriorityWithoutResorting(COIN_PRIORITY);

    sprite.size = Vector2(20, 20);
  }

  void setPersonalGameRef(MyGame gameRef) {
    personalGameRef = gameRef;
  }

  @override
  void resize(Vector2 newSize, double xRatio, double yRatio) {
    super.resize(newSize, xRatio, yRatio);
    sprite.x *= xRatio;
    sprite.y *= yRatio;
    sprite.width *= xRatio;
    sprite.height *= yRatio;
  }

  void renderCoinScore(Canvas c) {
    sprite.animation?.getSprite().render(c,
        position:
            Vector2(personalGameRef.camera.viewport.canvasSize!.x - 70, 10),
        size: Vector2(20, 20));
  }

  List<Sprite> getCoin() {
    return coin;
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generateCoins(bool start) {
    Platform platform = Platform(gameRef);
    if ((objects == null ||
            objects.length != 9 ||
            gameRef.runnerColumn + BUFFER < lastPlaced) &&
        !start) {
      return;
    } else {
      int colBegin = lastPlaced + 1;
      for (var r = 0; r < 9; r++) {
        for (var c = colBegin; c < COL && c < colBegin + BUFFER; c++) {
          if (gameRef.course[r][c] == 'c') {
            generateCoin(gameRef, r,
                xPosition:
                    (c - gameRef.runnerColumn + 3) * platform.sprite.width,
                column: c);
          }
          lastPlaced = c;
        }
      }
      return;
    }
  }

  bool generateCoin(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0, int column = -1}) {
    Coin coin = Coin(gameRef);
    if (column >= 0) {
      coin.setColumn(column);
    }
    coin.setPosition(xPosition, gameRef.blockSize * level);

    objects[level].add(coin);
    gameRef.add(coin.sprite);

    return false;
  }
}
