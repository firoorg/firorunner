import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

class GameState extends Component {
  int start = 0;
  bool isPaused = false;
  int numCoins = 0;
  int distance = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      distance = DateTime.now().microsecondsSinceEpoch - start;
    }
  }

  void addCoin() {
    numCoins++;
  }

  void setUp() {
    numCoins = 0;
    distance = 0;
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

  double getVelocity() {
    if (!isPaused) {
      switch (getLevel()) {
        case 7:
          return 250.0;
        case 6:
          return 200.0;
        case 5:
          return 180.0;
        case 4:
          return 160.0;
        case 3:
          return 140.0;
        case 2:
          return 120.0;
        default:
          return 100.0;
      }
    } else {
      return 0;
    }
  }
}
