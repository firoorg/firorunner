import 'package:firo_runner/course.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

// Class the holds the game state and several functions related to score and
// speed.
class GameState extends Component {
  int start = 0;
  bool isPaused = false;
  bool inMatch = false;
  int numCoins = 0;
  int time = 0;
  final double desiredPlatSize = 14;
  double platSize = 14;
  double mult = 1.0;
  late MyGame gameRef;
  int previousLevel = 1;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      time = DateTime.now().microsecondsSinceEpoch - start;
      if (previousLevel != getLevel()) {
        previousLevel = getLevel();
        gameRef.fireworks.reset();
      }
    }
  }

  void addCoin() {
    numCoins++;
  }

  void setUp(MyGame gameRef) {
    this.gameRef = gameRef;
    platSize = gameRef.camera.viewport.canvasSize!.x /
        (gameRef.blockSize *
            (gameRef.platformHolder.l1[0].srcSize.x /
                gameRef.platformHolder.l1[0].srcSize.y));
    mult = desiredPlatSize / platSize;
    numCoins = 0;
    time = 0;
    previousLevel = 1;
    start = DateTime.now().microsecondsSinceEpoch;
    isPaused = false;
  }

  void setPaused() {
    isPaused = true;
  }

  // This is the level of the game.
  int getLevel() {
    int score = getScore();
    if (score > LEVEL7) {
      return 7;
    } else if (score > LEVEL6) {
      return 6;
    } else if (score > LEVEL5) {
      return 5;
    } else if (score > LEVEL4) {
      return 4;
    } else if (score > LEVEL3) {
      return 3;
    } else if (score > LEVEL2) {
      return 2;
    } else {
      return 1;
    }
  }

  // This determines the stages of the games and its animations.
  int getScoreLevel() {
    int score = getScore();
    if (score > LEVEL7) {
      return 12;
    } else if (score > LEVEL6 + LEVEL6 / 2) {
      return 11;
    } else if (score > LEVEL6) {
      return 10;
    } else if (score > LEVEL5 + LEVEL5 / 2) {
      return 9;
    } else if (score > LEVEL5) {
      return 8;
    } else if (score > LEVEL4 + LEVEL4 / 2) {
      return 7;
    } else if (score > LEVEL4) {
      return 6;
    } else if (score > LEVEL3 + LEVEL3 / 2) {
      return 5;
    } else if (score > LEVEL3) {
      return 4;
    } else if (score > LEVEL2 + LEVEL2 / 2) {
      return 3;
    } else if (score > LEVEL2) {
      return 2;
    } else if (score > LEVEL2 - LEVEL2 / 2) {
      return 1;
    } else {
      return 0;
    }
  }

  // This score is used to determine the danger level of the game,
  // and progression.
  int getScore() {
    return gameRef.runnerColumn + numCoins * 2;
  }

  // Gets how long the player has been playing the game.
  int getPlayerTime() {
    return time ~/ 1000000;
  }

  // Get the relative pixel velocity at the current moment.
  double getVelocity() {
    if (!isPaused) {
      switch (getLevel()) {
        case 7:
          return gameRef.size.x *
              (0.30 + ((2.0 * gameRef.runnerColumn) / COL)) *
              mult;
        case 6:
          return gameRef.size.x * 0.28 * mult;
        case 5:
          return gameRef.size.x * 0.26 * mult;
        case 4:
          return gameRef.size.x * 0.24 * mult;
        case 3:
          return gameRef.size.x * 0.22 * mult;
        case 2:
          return gameRef.size.x * 0.20 * mult;
        default:
          return gameRef.size.x * 0.18 * mult;
      }
    } else {
      return 0;
    }
  }

  // Returns the level of the Robot, used to determine what animations it uses.
  int getRobotLevel() {
    if (numCoins > COINS_ROBOT_UPGRADE2) {
      return 3;
    } else if (numCoins > COINS_ROBOT_UPGRADE1) {
      return 2;
    } else {
      return 1;
    }
  }
}
