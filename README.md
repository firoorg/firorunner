<a href="https://play.google.com/store/apps/details?id=com.cypherstack.firorunner" target="_blank">
  <img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" height="80"/>
</a>

# firo_runner

An infitite runner game powered by Firo.

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
