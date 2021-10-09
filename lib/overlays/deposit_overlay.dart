import 'package:flutter/material.dart';

import '../main.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DepositOverlay extends StatelessWidget {
  const DepositOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Color textColor = Colors.cyan;
  final Color cardColor = const Color(0xff262b3f);
  final Color titleColor = const Color(0xff68d9cc);

  final MyGame game;

  List<Widget> getDepositAddress(double width) {
    List<Widget> list = [];
    if (game.address.length != 34) {}
    list.add(QrImage(
      data: game.address,
      version: QrVersions.auto,
      size: width / 5,
      backgroundColor: Colors.white,
    ));
    list.add(Padding(
      padding: EdgeInsets.all(width * 0.01),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: titleColor, width: 3),
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: EdgeInsets.all(width * 0.01),
          child: SelectableText(
            game.address,
            style: TextStyle(
              color: textColor,
              fontSize: width * 0.03,
            ),
          ),
        ),
      ),
    ));
    return list;
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
                children: getDepositAddress(width),
              ),
            ),
          ),
        ),
        onTap: () {
          game.overlays.remove('deposit');
        },
      ),
    );
  }
}
