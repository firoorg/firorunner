import 'package:firo_runner/course.dart';
import 'package:firo_runner/holders/holder.dart';
import 'package:firo_runner/main.dart';
import 'package:firo_runner/moving_objects/moving_object.dart';
import 'package:flame/components.dart';
import 'package:firo_runner/moving_objects/platform.dart';

class PlatformHolder extends Holder {
  late List<Sprite> l1;
  late List<Sprite> l2;
  late List<Sprite> m1;
  late List<Sprite> m2;
  late List<Sprite> r1;
  late List<Sprite> r2;
  late List<Sprite> o1;
  late List<Sprite> o2;
  bool noTopObstaclesForNext = false;
  bool noMiddleObstaclesForNext = false;
  int timeSinceLastTopHole = 0;
  int timeSinceLastBottomHole = 0;

  @override
  Future load(MyGame gameRef) async {
    super.load(gameRef);
    List<Sprite> allPlatforms = await loadListSprites(
        "platform", "platforms", 40,
        sheets: 1, frameSize: Vector2(318, 256));
    l1 = allPlatforms.sublist(0, 5);
    l2 = allPlatforms.sublist(5, 10);
    m1 = allPlatforms.sublist(10, 15);
    m2 = allPlatforms.sublist(15, 20);
    r1 = allPlatforms.sublist(20, 25);
    r2 = allPlatforms.sublist(25, 30);
    o1 = allPlatforms.sublist(30, 35);
    o2 = allPlatforms.sublist(35, 40);
  }

  @override
  void setUp() {
    timeSinceLastTopHole = 0;
    timeSinceLastBottomHole = 0;
    super.setUp();
  }

  // Generate all the platforms in the game.
  // Including top openings, and bottom structures.
  void generatePlatforms(bool start) {
    Platform platform = Platform(gameRef);
    if ((objects == null ||
            objects.length != 9 ||
            gameRef.runnerColumn + BUFFER < gameRef.renderColumn) &&
        !start) {
      return;
    } else {
      int colBegin = lastPlaced + 1;
      for (var r = 2; r < 9; r = r + 3) {
        for (var c = colBegin; c < COL && c < colBegin + BUFFER; c++) {
          if (gameRef.course[r][c] == 'p') {
            generatePlatform(gameRef, r,
                xPosition:
                    (c - gameRef.runnerColumn + 3) * platform.sprite.width -
                        gameRef.offset,
                column: c);
          }
          lastPlaced = c;
          gameRef.renderColumn = lastPlaced;
        }
      }
      return;
    }
  }

  // Remove and object from this holder.
  @override
  void remove(List<MovingObject> levelHolder, int j) {
    int runCol = (((levelHolder[j] as Platform).sprite.position.x -
                            gameRef.runner.runnerPosition.x)
                        .abs() /
                    (levelHolder[j] as Platform).sprite.width +
                (levelHolder[j] as Platform).column)
            .ceil() +
        1;
    double offset = ((levelHolder[j] as Platform).sprite.position.x).abs() %
        (levelHolder[j] as Platform).sprite.width;
    gameRef.offset = offset;
    gameRef.runnerColumn = runCol;
    super.remove(levelHolder, j);
  }

  // Create a platform object.
  bool generatePlatform(MyGame gameRef, int level,
      {double xPosition = 0, int column = -1}) {
    double xCoordinate = xPosition;
    if (objects[level].isNotEmpty && xPosition == 0) {
      xCoordinate = objects[level].last.getRightEnd();
    }

    Platform platform = Platform(gameRef);
    platform.setPosition(xCoordinate, gameRef.blockSize * level);
    if (column >= 0) {
      platform.setColumn(column);
    }
    platform.row = level;
    gameRef.add(platform.sprite);
    objects[level].add(platform);
    if (level == 2 && noTopObstaclesForNext) {
      platform.prohibitObstacles = true;
      noTopObstaclesForNext = false;
    } else if (level == 5 && noMiddleObstaclesForNext) {
      platform.prohibitObstacles = true;
      noMiddleObstaclesForNext = false;
    }
    return false;
  }

  // Choose a random platform that is off screen from the player.
  Platform? getPlatformOffScreen(int level) {
    for (int i = 0; i < objects[level].length; i++) {
      Platform p = objects[level][i] as Platform;
      if (p.sprite.x > p.gameRef.size.x) {
        int chosenIndex = random.nextInt(objects[level].length - i) + i;
        return objects[level][chosenIndex] as Platform;
      }
    }
    return null;
  }
}
