import 'dart:math';

import 'package:firo_runner/moving_objects/moving_object.dart';

import 'package:firo_runner/main.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

class Holder {
  Random random = Random();
  int lastPlaced = -1;
  late MyGame gameRef;

  late List<List<MovingObject>> objects = [];

  // Load method to be overridden by classes that extend this.
  Future load(MyGame gameRef) async {
    this.gameRef = gameRef;
  }

  // Basic method to reset the state of the holder object.
  void setUp() {
    for (int i = 0; i < objects.length; i++) {
      for (int j = 0; j < objects[i].length; j++) {
        remove(objects[i], j);
      }
    }
    objects = [];
    for (int i = 0; i < 9; i++) {
      objects.add([]);
    }
    lastPlaced = -1;
  }

  // Get the total amount of objects currently in the logical game.
  int total() {
    int total = 0;
    for (List<MovingObject> levelObjects in objects) {
      total += levelObjects.length;
    }
    return total;
  }

  // Update every object that this holder holds.
  void update(double dt) {
    if (gameRef.gameState.isPaused) return;
    for (List<MovingObject> objectLevel in objects) {
      for (MovingObject p in objectLevel) {
        p.update(dt);
      }
    }
  }

  // Remove and object from this holder.
  void remove(List<MovingObject> levelHolder, int j) {
    levelHolder[j].remove();
    levelHolder.removeAt(j);
  }

  // Remove any object is past rendering distance.
  void removePast(MyGame gameRef) {
    for (List<MovingObject> objectLevel in objects) {
      for (int i = 0; i < objectLevel.length;) {
        if (objectLevel[i].sprite.x + objectLevel[i].sprite.width < 0) {
          remove(objectLevel, i);
          continue;
        }
        i++;
      }
    }
  }

  // Resize this object for screen rotations or changing window size.
  void resize(Vector2 newSize, double xRatio, double yRatio) {
    for (List<MovingObject> platformLevel in objects) {
      for (MovingObject p in platformLevel) {
        p.resize(newSize, xRatio, yRatio);
      }
    }
  }

  // Load sprites dynamically.
  Future<List<Sprite>> loadListSprites(
      String folderName, String extraName, int howManyFrames,
      {int sheets = 0, Vector2? frameSize}) async {
    List<Sprite> sprites = [];
    if (sheets != 0 && frameSize != null) {
      int currentSprite = 0;
      for (int index = 0; index < sheets; index++) {
        Image sheet =
            await Flame.images.load('$folderName/$extraName-$index.png');
        SpriteSheet spriteSheet = SpriteSheet(image: sheet, srcSize: frameSize);

        for (int i = 0;
            (i < spriteSheet.rows * spriteSheet.columns) &&
                currentSprite < howManyFrames;
            i++) {
          sprites.add(spriteSheet.getSpriteById(i));
          currentSprite++;
        }
      }
    } else {
      for (int i = 0; i < howManyFrames; i++) {
        sprites.add(Sprite(
          await Flame.images.load('$folderName/${extraName}_$i.png'),
        ));
      }
    }

    return sprites;
  }
}
