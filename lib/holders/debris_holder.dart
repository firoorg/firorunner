import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:firo_runner/moving_objects/debris.dart';
import 'package:firo_runner/main.dart';

import '../course.dart';

class DebrisHolder extends Holder {
  late List<Sprite> debris;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    debris = await loadListSprites("debris", "debris", 21,
        sheets: 1, frameSize: Vector2(360, 1000));
  }

  List<Sprite> getDebris() {
    return debris;
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generateDebris_(bool start) {
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
          if (gameRef.course[r][c] == 'd') {
            generateDebris(gameRef, r,
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

  bool generateDebris(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0, int column = -1}) {
    Debris debris = Debris(gameRef);
    if (column >= 0) {
      debris.setColumn(column);
    }
    debris.setPosition(
        xPosition, gameRef.blockSize * level - gameRef.blockSize / 3);

    objects[level].add(debris);
    gameRef.add(debris.sprite);
    return false;
  }
}
