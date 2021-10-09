import 'package:flutter/material.dart';

import 'main.dart';

class LeaderBoardOverlay extends StatelessWidget {
  const LeaderBoardOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Color textColor = Colors.cyan;
  final Color cardColor = const Color(0xff262b3f);
  final Color borderColor = const Color(0xdfd675e1);
  final Color titleColor = const Color(0xff68d9cc);

  // final Color textColor = Colors.black;

  final MyGame game;

  List<Card> getLeaderboard(double width) {
    List<Card> leaders = [];
    List<String> list = game.leaderboard.split("\n");

    if (list.isEmpty || list.length % 2 != 1 || list.length == 1) {
      leaders.add(
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: titleColor, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(width * 0.01),
                  child: Text(
                    "No Internet Connection.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.03,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
      return leaders;
    }

    leaders.add(
      Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: titleColor, width: 3),
            borderRadius: BorderRadius.circular(10.0)),
        child: FractionallySizedBox(
          widthFactor: 0.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(width * 0.01),
                child: Text(
                  "Username",
                  style: TextStyle(
                    color: textColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
              SizedBox(
                width: width / 11,
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.01),
                child: Text(
                  "Score",
                  style: TextStyle(
                    color: textColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (int i = 0; i < list.length - 2; i = i + 2) {
      String name = list.elementAt(i);
      String score = list.elementAt(i + 1);
      leaders.add(
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
          child: FractionallySizedBox(
            widthFactor: 0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(width * 0.01),
                  child: Text(
                    name.substring(0, name.length < 10 ? name.length : 10),
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
                SizedBox(
                  width: width / 11,
                ),
                Padding(
                  padding: EdgeInsets.all(width * 0.01),
                  child: Text(
                    score,
                    style: TextStyle(
                      color: textColor,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return leaders;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Center(
          child: Container(
            height: game.viewport.canvasSize.y,
            width: game.viewport.canvasSize.x,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: lossImage,
                fit: BoxFit.fill,
              ),
            ),
            child: SizedBox(
              width: width / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getLeaderboard(width),
              ),
            ),
          ),
        ),
        onTap: () {
          game.overlays.remove('leaderboard');
        },
      ),
    );
  }
}
