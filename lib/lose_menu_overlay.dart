import 'package:flutter/material.dart';

import 'main.dart';

class LoseMenuOverlay extends StatelessWidget {
  const LoseMenuOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: game.viewport.canvasSize.y,
        width: game.viewport.canvasSize.x,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/overlay100.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: ' + game.gameState.getPlayerScore().toString(),
              style: overlayText,
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
                      image: DecorationImage(
                          image: AssetImage('assets/images/button.png'),
                          fit: BoxFit.fill),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        " Main Menu ",
                        style: overlayText,
                      ),
                    ),
                  ),
                  // ),
                  onPressed: () {
                    // Go to the Main Menu
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
                      image: DecorationImage(
                          image: AssetImage('assets/images/button.png'),
                          fit: BoxFit.fill),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        " Replay ",
                        style: overlayText,
                      ),
                    ),
                  ),
                  // ),
                  onPressed: () {
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
