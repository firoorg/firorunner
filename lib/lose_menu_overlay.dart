import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'main.dart';

import 'package:audioplayers/src/api/player_mode.dart';

class LoseMenuOverlay extends StatelessWidget {
  const LoseMenuOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: game.viewport.canvasSize.y,
        width: game.viewport.canvasSize.x,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: lossImage,
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              type: MaterialType.transparency,
              child: Text(
                'Score: ${game.gameState.getPlayerScore()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.05,
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  splashColor: Colors.greenAccent,
                  elevation: 8.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image:
                          DecorationImage(image: buttonImage, fit: BoxFit.fill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "     MAIN MENU     ",
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: width * 0.03,
                        ),
                      ),
                    ),
                  ),
                  // ),
                  onPressed: () async {
                    // Go to the Main Menu
                    await FlameAudio.audioCache.play('sfx/button_click.mp3',
                        mode: PlayerMode.LOW_LATENCY);
                    game.mainMenu();
                  },
                ),
                const SizedBox(
                  width: 32.0,
                ),
                MaterialButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  splashColor: Colors.greenAccent,
                  elevation: 8.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image:
                          DecorationImage(image: buttonImage, fit: BoxFit.fill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "    REPLAY    ",
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: width * 0.03,
                        ),
                      ),
                    ),
                  ),
                  // ),
                  onPressed: () async {
                    await FlameAudio.audioCache.play('sfx/button_click.mp3',
                        mode: PlayerMode.LOW_LATENCY);
                    game.runner.friend = await FlameAudio.audioCache
                        .loop('sfx/robot_friend_beep.mp3');
                    game.reset();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
