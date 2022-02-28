# firo_runner

An infinite runner game powered by Firo. Live version available on [firorunner.com](firorunner.com)

# About Tournament Mode
Leaderboard resets and payouts are made every Sunday UTC 0:00.

Top 5 scores every week will share the pot in the following proportions:
- 1st: 50%
- 2nd: 25%
- 3rd: 15%
- 4th: 5%
- 5th: 5%

Firo that is deposited to play in tournament mode are distributed as follows:
- 50% Winners' Pot
- 25% Firo Development Fund
- 25% Cypherstack

We welcome community contributions!

## Getting Started

To build follow [tutorials](https://youtu.be/x0uinJvhNxI?t=1114) on setting up a flutter development enviornment.

Once you can build a default flutter application, you should be able to build the program.

Simply git clone this repository, and open it up in an editor of your choice whether Android Studio or Visual Code, and if you have flutter and Dart plugins installed you should be able to build for any device.

If solely using the command line
1) set up your flutter development enviornment
2) git clone the repository
3) go into repository with terminal
4) type: flutter pub get
5) type depending on what device you are building for:
```
flutter build apk --bundle-sksl-path flutter_01.sksl.json --release
// or
flutter build web --web-renderer canvaskit --release
```

To connect to the server in tournament mode, set the variables in main.dart to the correct values of the server
```
const SERVER = "http://serveripaddress";
const PORT = "portnumber";
```

If you are not interested in playing in tournament mode, simply set the following variable to true in main.dart
```
const NO_TOURNAMENT = true;
```
