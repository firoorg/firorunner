import 'package:firo_runner/biome.dart';
import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';

// Class the holds the game state and several functions related to score and
// speed.
class GameState extends Component {
  int start = 0;
  bool isPaused = false;
  int numCoins = 0;
  int time = 0;
  late MyGame gameRef;
  int previousLevel = 1;

  /// The current biome, derived from the game level.
  Biome currentBiome = Biome.city;

  /// The previous biome, used to detect biome transitions.
  Biome previousBiome = Biome.city;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      time = DateTime.now().microsecondsSinceEpoch - start;
      if (previousLevel != getLevel()) {
        previousLevel = getLevel();
        gameRef.fireworks.reset();
      }
      // Update biome tracking.
      Biome newBiome = getBiomeForLevel(getLevel());
      if (newBiome != currentBiome) {
        previousBiome = currentBiome;
        currentBiome = newBiome;
      }
    }
  }

  void addCoin() {
    numCoins++;
  }

  void setUp(MyGame gameRef) {
    this.gameRef = gameRef;
    numCoins = 0;
    time = 0;
    previousLevel = 1;
    currentBiome = Biome.city;
    previousBiome = Biome.city;
    start = DateTime.now().microsecondsSinceEpoch;
    isPaused = false;
  }

  void setPaused() {
    isPaused = true;
  }

  // This is the level of the game, extended for biome progression.
  int getLevel() {
    if (time > LEVEL16) {
      return 16;
    } else if (time > LEVEL15) {
      return 15;
    } else if (time > LEVEL14) {
      return 14;
    } else if (time > LEVEL13) {
      return 13;
    } else if (time > LEVEL12) {
      return 12;
    } else if (time > LEVEL11) {
      return 11;
    } else if (time > LEVEL10) {
      return 10;
    } else if (time > LEVEL9) {
      return 9;
    } else if (time > LEVEL8) {
      return 8;
    } else if (time > LEVEL7) {
      return 7;
    } else if (time > LEVEL6) {
      return 6;
    } else if (time > LEVEL5) {
      return 5;
    } else if (time > LEVEL4) {
      return 4;
    } else if (time > LEVEL3) {
      return 3;
    } else if (time > LEVEL2) {
      return 2;
    } else {
      return 1;
    }
  }

  // This determines the stages of the games and its animations.
  // Extended for biome levels: 0-12 for city, 13+ for new biomes.
  int getScoreLevel() {
    int score = getScore();
    if (score > LEVEL16) {
      return 22;
    } else if (score > LEVEL15) {
      return 21;
    } else if (score > LEVEL14) {
      return 20;
    } else if (score > LEVEL13) {
      return 19;
    } else if (score > LEVEL12) {
      return 18;
    } else if (score > LEVEL11) {
      return 17;
    } else if (score > LEVEL10) {
      return 16;
    } else if (score > LEVEL9) {
      return 15;
    } else if (score > LEVEL8) {
      return 14;
    } else if (score > LEVEL7) {
      return 13;
    } else if (score > LEVEL6 + LEVEL6 ~/ 2) {
      return 12;
    } else if (score > LEVEL6) {
      return 10;
    } else if (score > LEVEL5 + LEVEL5 ~/ 2) {
      return 9;
    } else if (score > LEVEL5) {
      return 8;
    } else if (score > LEVEL4 + LEVEL4 ~/ 2) {
      return 7;
    } else if (score > LEVEL4) {
      return 6;
    } else if (score > LEVEL3 + LEVEL3 ~/ 2) {
      return 5;
    } else if (score > LEVEL3) {
      return 4;
    } else if (score > LEVEL2 + LEVEL2 ~/ 2) {
      return 3;
    } else if (score > LEVEL2) {
      return 2;
    } else if (score > LEVEL2 - LEVEL2 ~/ 2) {
      return 1;
    } else {
      return 0;
    }
  }

  // Gets the danger level of the game, this determines the appearance of
  // obstacles in the beginning of the game.
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

  // This score is used to determine the danger level of the game,
  // and progression.
  int getScore() {
    return time ~/ 10 + numCoins * 1000000;
  }

  // This is the real score that the player sees.
  int getPlayerScore() {
    return getScore() ~/ 10000;
  }

  // Gets how long the player has been playing the game.
  int getPlayerTime() {
    return time ~/ 1000000;
  }

  // Get the relative pixel velocity at the current moment.
  // Extended with gradually increasing speeds for new biome levels.
  double getVelocity() {
    if (!isPaused) {
      switch (getLevel()) {
        case 16:
          return gameRef.viewport.canvasSize.x * 0.48;
        case 15:
          return gameRef.viewport.canvasSize.x * 0.46;
        case 14:
          return gameRef.viewport.canvasSize.x * 0.44;
        case 13:
          return gameRef.viewport.canvasSize.x * 0.42;
        case 12:
          return gameRef.viewport.canvasSize.x * 0.40;
        case 11:
          return gameRef.viewport.canvasSize.x * 0.38;
        case 10:
          return gameRef.viewport.canvasSize.x * 0.36;
        case 9:
          return gameRef.viewport.canvasSize.x * 0.34;
        case 8:
          return gameRef.viewport.canvasSize.x * 0.32;
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

  /// Returns the current biome configuration for the active level.
  BiomeConfig getCurrentBiomeConfig() {
    return getBiomeConfigForLevel(getLevel());
  }
}
