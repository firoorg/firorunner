import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/src/api/player_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({
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
            image: mainMenuImage,
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: NO_TOURNAMENT
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    MaterialButton(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      textColor: Colors.white,
                      splashColor: Colors.greenAccent,
                      elevation: 8.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: buttonImage, fit: BoxFit.fill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "      START      ",
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: width * 0.025,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // Go to the Main Menu
                        FlameAudio.audioCache.play('sfx/menu_button.mp3',
                            mode: PlayerMode.LOW_LATENCY);
                        game.competitive = false;
                        game.reset();
                        game.runner.boost = FlameAudio.audioCache.play(
                            'sfx/laser.mp3',
                            volume: 0.0,
                            mode: PlayerMode.LOW_LATENCY);
                        FlameAudio.bgm.stop();
                        FlameAudio.bgm.play('Infinite_Spankage_M.mp3');
                        game.runner.friend = await FlameAudio.audioCache.loop(
                            'sfx/robot_friend_beep.mp3',
                            volume: 0.25,
                            mode: PlayerMode.LOW_LATENCY);
                      },
                    ),
                  ],
                ),
                NO_TOURNAMENT
                    ? const SizedBox(
                        height: 16.0,
                      )
                    : Row(
                        children: [
                          MaterialButton(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            textColor: Colors.white,
                            splashColor: Colors.greenAccent,
                            elevation: 8.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: buttonImage, fit: BoxFit.fill),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "    DEPOSIT    ",
                                  style: TextStyle(
                                    color: game.username == ""
                                        ? Colors.grey
                                        : Colors.cyan,
                                    fontSize: width * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: game.username == ""
                                ? null
                                : () async {
                                    game.address = await game.connectServer(
                                        "deposit", "user=${game.username}");
                                    FlameAudio.audioCache.play(
                                        'sfx/button_click.mp3',
                                        mode: PlayerMode.LOW_LATENCY);
                                    game.overlays.add("deposit");
                                  },
                          ),
                          MaterialButton(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            textColor: Colors.white,
                            splashColor: Colors.greenAccent,
                            elevation: 8.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: buttonImage, fit: BoxFit.fill),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "       TOURNAMENT   ${game.tries}       ",
                                  style: TextStyle(
                                    color:
                                        game.username == "" || game.tries == 0
                                            ? Colors.grey
                                            : Colors.cyan,
                                    fontSize: width * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: game.username == "" || game.tries == 0
                                ? null
                                : () async {
                                    // Go to the Main Menu
                                    FlameAudio.audioCache.play(
                                        'sfx/menu_button.mp3',
                                        mode: PlayerMode.LOW_LATENCY);
                                    game.runner.boost = FlameAudio.audioCache
                                        .play('sfx/laser.mp3',
                                            volume: 0.0,
                                            mode: PlayerMode.LOW_LATENCY);
                                    game.competitive = true;
                                    game.reset();
                                    FlameAudio.bgm.stop();
                                    FlameAudio.bgm
                                        .play('Infinite_Spankage_M.mp3');
                                    game.runner.friend = await FlameAudio
                                        .audioCache
                                        .loop('sfx/robot_friend_beep.mp3',
                                            volume: 0.25,
                                            mode: PlayerMode.LOW_LATENCY);
                                  },
                          ),
                        ],
                      ),
                NO_TOURNAMENT
                    ? const SizedBox(
                        height: 16.0,
                      )
                    : Row(
                        children: [
                          MaterialButton(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            textColor: Colors.white,
                            splashColor: Colors.greenAccent,
                            elevation: 8.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: buttonImage, fit: BoxFit.fill),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "    ${game.username == "" ? "SIGN IN" : game.username}    ",
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: width * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              FlameAudio.audioCache.play('sfx/button_click.mp3',
                                  mode: PlayerMode.LOW_LATENCY);
                              game.overlays.add("signin");
                            },
                          ),
                          MaterialButton(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            textColor: Colors.white,
                            splashColor: Colors.greenAccent,
                            elevation: 8.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: buttonImage, fit: BoxFit.fill),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "     LEADER BOARD     ",
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: width * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              game.leaderboard = await game.connectServer(
                                  "leaderboard", "user=value");
                              FlameAudio.audioCache.play('sfx/button_click.mp3',
                                  mode: PlayerMode.LOW_LATENCY);
                              game.overlays.add("leaderboard");
                            },
                          ),
                        ],
                      ),
              ],
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
          ],
        ),
      ),
    );
  }
}
