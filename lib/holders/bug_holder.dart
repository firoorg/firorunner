import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/moving_objects/platform.dart';
import 'package:flame/components.dart';

import 'package:firo_runner/moving_objects/bug.dart';
import 'package:firo_runner/main.dart';

import '../course.dart';

class BugHolder extends Holder {
  late List<Sprite> bug;
  late List<Sprite> breaking;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    bug = await loadListSprites("bug", "bug", 8,
        sheets: 1, frameSize: Vector2(512, 512));
    breaking = await loadListSprites("bug", "bug_break", 13,
        sheets: 1, frameSize: Vector2(512, 512));
  }

  List<Sprite> getBug(String state) {
    switch (state) {
      case "normal":
        return bug;
      default:
        return breaking;
    }
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generateBugs(bool start) {
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
          if (gameRef.course[r][c] == 'b') {
            generateBug(gameRef, r,
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

  // Generate a bug on the indicated level if it is possible.
  bool generateBug(MyGame gameRef, int level,
      {bool force = false, double xPosition = 0, int column = -1}) {
    Bug bug = Bug(gameRef);
    if (column >= 0) {
      bug.setColumn(column);
    }
    bug.setPosition(xPosition, gameRef.blockSize * level);

    objects[level].add(bug);
    gameRef.add(bug.sprite);
    return false;
  }
}
