import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

class GameState extends Component {
  int start = 0;
  bool isPaused = false;
  int numCoins = 0;
  int distance = 0;
  late MyGame gameRef;
  int previousLevel = 1;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      distance = DateTime.now().microsecondsSinceEpoch - start;
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
    numCoins = 0;
    distance = 0;
    previousLevel = 1;
    start = DateTime.now().microsecondsSinceEpoch;
    isPaused = false;
  }

  void setPaused() {
    isPaused = true;
  }

  int getLevel() {
    if (distance > LEVEL7) {
      return 7;
    } else if (distance > LEVEL6) {
      return 6;
    } else if (distance > LEVEL5) {
      return 5;
    } else if (distance > LEVEL4) {
      return 4;
    } else if (distance > LEVEL3) {
      return 3;
    } else if (distance > LEVEL2) {
      return 2;
    } else {
      return 1;
    }
  }

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

  int getDangerLevel() {
    int score = getScore();
    if (score > LEVEL2 / 2 + LEVEL2 / (2 * 4)) {
      return 5;
    } else if (score > LEVEL2 / 2) {
      return 4;
    } else if (score > LEVEL2 / 2 - LEVEL2 / (2 * 4)) {
      return 3;
    } else if (score > LEVEL2 / 2 - 2 * LEVEL2 / (2 * 4)) {
      return 2;
    } else if (score > LEVEL2 / 2 - 3 * LEVEL2 / (2 * 4)) {
      return 1;
    } else {
      return 0;
    }
  }

  int getScore() {
    return distance ~/ 10 + numCoins * 1000000;
  }

  int getPlayerScore() {
    return getScore() ~/ 10000;
  }

  int getPlayerDistance() {
    return distance ~/ 1000000;
  }

  double getVelocity() {
    if (!isPaused) {
      switch (getLevel()) {
        case 7:
          return gameRef.viewport.canvasSize.x * 0.30;
        case 6:
          return gameRef.viewport.canvasSize.x * 0.28;
        case 5:
          return gameRef.viewport.canvasSize.x * 0.26;
        case 4:
          return gameRef.viewport.canvasSize.x * 0.24;
        case 3:
          return gameRef.viewport.canvasSize.x * 0.22;
        case 2:
          return gameRef.viewport.canvasSize.x * 0.20;
        default:
          return gameRef.viewport.canvasSize.x * 0.18;
      }
    } else {
      return 0;
    }
  }

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
