import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/wire.dart';
import 'package:firo_runner/main.dart';

import '../course.dart';

class WireHolder extends Holder {
  late List<Sprite> wire;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    wire = await loadListSprites("wire", "wire", 12,
        sheets: 1, frameSize: Vector2(512, 512));
  }

  List<Sprite> getWire() {
    return wire;
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generateWires(bool start) {
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
          if (gameRef.course[r][c] == 'w') {
            generateWire(gameRef, r,
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

  bool generateWire(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0, int column = -1}) {
    Wire wire = Wire(gameRef);
    if (column >= 0) {
      wire.setColumn(column);
    }
    wire.sprite.flipHorizontally();
    if (level % 3 == 0) {
      wire.sprite.anchor = Anchor.center;
      wire.sprite.flipVertically();

      wire.setPosition(
          xPosition, gameRef.blockSize * level + 2 * gameRef.blockSize / 7);
    } else {
      wire.setPosition(
          xPosition, gameRef.blockSize * level + gameRef.blockSize / 10);
    }

    objects[level].add(wire);
    gameRef.add(wire.sprite);
    return false;
  }
}
