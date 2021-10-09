import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'package:audioplayers/src/api/player_mode.dart';

/// This is the stateful widget that the main application instantiates.
class SignInOverlay extends StatefulWidget {
  const SignInOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Color cardColor = Colors.white;
  final Color textColor = Colors.black;

  final MyGame game;

  @override
  State<SignInOverlay> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<SignInOverlay> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Center(
          child: Container(
            height: widget.game.viewport.canvasSize.y,
            width: widget.game.viewport.canvasSize.x,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: lossImage,
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 2 * width / 3,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    color: Colors.white,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your account name',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your account name';
                              } else if (value.contains(' ')) {
                                return 'Please input a valid account name without any spaces';
                              }
                              return null;
                            },
                            controller: accountController,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your receiving Firo address.',
                            ),
                            validator: (String? value) {
                              // if (value == null || value.isEmpty) {
                              //   return 'Please enter your receiving Firo address.';
                              // } else
                              if (value == null || value.isEmpty) {
                                print("logging in instead of signing up.");
                                return null;
                              } else if (value.length != 34) {
                                return 'Not a valid receiving Firo address.';
                              }
                              return null;
                            },
                            controller: keyController,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                // // Validate will return true if the form is valid, or false if
                                // // the form is invalid.
                                FlameAudio.audioCache.play(
                                    'sfx/button_click.mp3',
                                    mode: PlayerMode.LOW_LATENCY);
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                // Process data.
                                String account = accountController.text;
                                String key = keyController.text;

                                String username = await widget.game.connectServer(
                                    "newuser",
                                    "user=$account&receive=${key == "" ? "dud" : key}");

                                if (username.toLowerCase().contains("error")) {
                                  print("There was an error");
                                } else {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('username', username);
                                  widget.game.username =
                                      prefs.getString('username') ?? "";
                                  try {
                                    String result = await widget.game
                                        .connectServer(
                                            "gettries", "user=$username");
                                    widget.game.tries = int.parse(result);
                                    prefs.setInt('tries', widget.game.tries);
                                  } catch (e) {
                                    print(e);
                                  }
                                }

                                widget.game.overlays.remove('signin');
                              },
                              child: const Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          widget.game.overlays.remove('signin');
        },
      ),
    );
  }
}
