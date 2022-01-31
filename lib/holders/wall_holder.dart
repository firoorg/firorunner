import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/wall.dart';
import 'package:firo_runner/main.dart';

import '../course.dart';

class WallHolder extends Holder {
  late List<Sprite> wall;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    wall = await loadListSprites("wall", "wall", 5,
        sheets: 1, frameSize: Vector2(163, 1000));
  }

  List<Sprite> getWall() {
    return wall;
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generateWalls(bool start) {
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
          if (gameRef.course[r][c] == '|') {
            generateWall(gameRef, r,
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

  bool generateWall(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0, int column = -1}) {
    Wall wall = Wall(gameRef);
    if (column >= 0) {
      wall.setColumn(column);
    }
    wall.setPosition(xPosition, gameRef.blockSize * level);
    wall.bottomPlatformLevel = level + 1;

    objects[level].add(wall);
    gameRef.add(wall.sprite);
    return false;
  }
}
