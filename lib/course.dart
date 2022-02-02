import 'dart:math';

// Rows in the game, not to be changed from 9.
const int ROW = 9;
// How many platforms to allow in the game. 100000 is approximately
// about 5 hours of playtime.
const int COL = 50000;
// How many columns ahead of runner should be loaded.
const int BUFFER = 20;

dynamic makeCourse(int seed) {
  var course = List.generate(
      ROW, (i) => List.generate(COL, (index) => i == 2 || i == 5 ? 'p' : ' '),
      growable: false);
  Random randomCourse = Random(seed);

  // Generate top holes.
  int timeSinceLastTopHole = 0;
  for (int index = 10; index < COL - 1; index++) {
    int chanceOfTopHole = randomCourse
        .nextInt(timeSinceLastTopHole > 0 ? timeSinceLastTopHole : 1);
    if (chanceOfTopHole > 50) {
      timeSinceLastTopHole = 0;
      course[2][index] = ' ';
      course[2][index + 1] = ' ';
      index = index + 1;
    } else {
      timeSinceLastTopHole++;
    }
  }

  // Generate bottom holes.
  int timeSinceLastBottomHole = 0;
  for (int index = 10; index < COL - 12; index++) {
    int chanceOfBottomHole = randomCourse
        .nextInt(timeSinceLastBottomHole > 0 ? timeSinceLastBottomHole : 1);
    if (chanceOfBottomHole > 30) {
      timeSinceLastBottomHole = 0;
      course[5][index] = ' ';
      course[5][index + 1] = ' ';
      course[5][index + 10] = ' ';
      course[5][index + 11] = ' ';

      for (var iteration = 0; iteration < 12; iteration++) {
        course[8][index + iteration] = 'p';
      }
      index = index + 11;
    } else {
      timeSinceLastBottomHole++;
    }
  }

  // Generate Bugs.
  for (int index = 10; index < COL; index++) {
    int chance = 0;
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(1, index, 'b', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(4, index, 'b', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(7, index, 'b', course);
    }
  }

  // Generate Debris.
  for (int index = 10; index < COL; index++) {
    int chance = 0;
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(0, index, 'd', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(3, index, 'd', course);
    }
  }

  // Generate Wires.
  for (int index = 10; index < COL; index++) {
    int chance = 0;
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(0, index, 'w', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(1, index, 'w', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(3, index, 'w', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(4, index, 'w', course);
    }
  }

  // Generate Walls.
  for (int index = 10; index < COL; index++) {
    int chance = 0;
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(1, index, '|', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(4, index, '|', course);
    }
  }

  // Generate Coins.
  for (int index = 10; index < COL; index++) {
    int chance = 0;
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(0, index, 'c', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(1, index, 'c', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(3, index, 'c', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(4, index, 'c', course);
    }
    chance = randomCourse.nextInt(1000);
    if (chance > 900) {
      placeObstacle(7, index, 'c', course);
    }
  }
  return course;
}

bool placeObstacle(int row, int column, String letter, var course) {
  int topPlatform = -1;
  int top = 0;
  int bottom = 1;
  int bottomPlatform = 2;
  if (row % 3 == 0) {
    topPlatform = row - 1;
    top = row;
    bottom = row + 1;
    bottomPlatform = row + 2;
  } else if (row % 3 == 1) {
    topPlatform = row - 2;
    top = row - 1;
    bottom = row;
    bottomPlatform = row + 1;
  } else {
    return false;
  }
  if (getChar(row, column, course) != ' ') {
    return false;
  }
  for (int index = column - 2; index <= column + 2; index++) {
    if (letter != 'c' &&
        (getChar(top, index, course) != ' ' ||
            getChar(bottom, index, course) != ' ')) {
      return false;
    }
    if (getChar(topPlatform, index, course) == ' ' ||
        getChar(bottomPlatform, index, course) == ' ') {
      return false;
    }
  }
  course[row][column] = letter;
  return true;
}

String getChar(int row, int column, var course) {
  if (column < 0 || column >= COL || row < 0 || row >= ROW) {
    return '';
  } else {
    return course[row][column];
  }
}
