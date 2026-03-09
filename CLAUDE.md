# CLAUDE.md

This file provides guidance for AI assistants working with the firo_runner codebase.

## Project Overview

**firo_runner** is an infinite runner game built with **Flutter** and the **Flame game engine** (v1.0.0-rc.11). A robot character navigates through progressively harder obstacles across 7 difficulty levels. The game supports Android, iOS, Web, Linux, and Windows, and includes an optional tournament mode with server connectivity for leaderboards.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build for specific platforms
flutter build apk --bundle-sksl-path flutter_01.sksl.json --release
flutter build web --web-renderer canvaskit --release
flutter build linux
flutter build windows
flutter build ios

# Run tests
flutter test

# Run linter
flutter analyze

# Format code
dart format lib/
```

## Project Structure

```
lib/
├── main.dart                  # Entry point, MyGame class, server config constants
├── runner.dart                # Player character with 30+ animation states
├── game_state.dart            # Score, velocity, level progression, difficulty
├── firework.dart              # Visual firework effects
├── holders/                   # Object pool managers (spawn, update, render, cleanup)
│   ├── holder.dart            # Base holder class
│   ├── platform_holder.dart
│   ├── coin_holder.dart
│   ├── bug_holder.dart
│   ├── wire_holder.dart
│   ├── debris_holder.dart
│   └── wall_holder.dart
├── moving_objects/            # Game entity classes extending MovingObject
│   ├── moving_object.dart     # Base class: sprite, position, velocity, collision
│   ├── platform.dart
│   ├── coin.dart
│   ├── bug.dart
│   ├── wire.dart
│   ├── debris.dart
│   ├── wall.dart
│   └── circuit_background.dart
└── overlays/                  # Flutter widget UI overlays
    ├── main_menu_overlay.dart
    ├── lose_menu_overlay.dart
    ├── leader_board_overlay.dart
    ├── sign_in_overlay.dart
    └── deposit_overlay.dart
```

**Other directories:** `assets/` (images, audio, fonts), `android/`, `ios/`, `linux/`, `windows/`, `web/` (platform-specific build scaffolding), `test/`.

## Architecture & Key Patterns

### Game Loop
`MyGame` extends Flame's `BaseGame` with `PanDetector`, `TapDetector`, and `KeyboardEvents` mixins. It owns all game systems (holders, runner, state, background).

### Object Holder Pattern
Each obstacle/collectible type has a `Holder` subclass that manages a pool of `MovingObject` instances. Holders handle spawning (level-based rates), updating, rendering, and off-screen cleanup. Each holder has 9 internal levels that map to game difficulty.

### Moving Object Base Class
All entities (platforms, coins, bugs, wires, debris, walls) extend `MovingObject`. This base class handles sprite animation, positioning, velocity application, and collision detection via `intersect()` which returns direction strings ("top", "bottom", "left", "right").

### Rendering Priority (Z-order)
Constants defined in `main.dart`:
- `OVERLAY_PRIORITY = 110`, `RUNNER_PRIORITY = 100`, `BUG_PRIORITY = 75`
- `COIN_PRIORITY = 70`, `PLATFORM_PRIORITY = 50`, `WALL_PRIORITY = 40`
- `DEBRIS_PRIORITY = 30`, `WIRE_PRIORITY = 25`, `FIREWORK_PRIORITY = 15`

### Input Handling
- **Desktop/Web:** Keyboard (WASD + arrow key alternatives)
- **Mobile:** Pan gestures and tap detection
- Unified through a `control(String)` method accepting "up", "down", "left", "right", "center"

### Difficulty Progression
7 levels triggered by score thresholds (`LEVEL2` through `LEVEL7` constants in `main.dart`). Each level increases velocity (18%-30% of viewport width) and obstacle spawn rates. Robot upgrades unlock at coin milestones (50, 100+).

### Tournament Mode
Controlled by constants in `main.dart`:
- `NO_TOURNAMENT` — set `true` for standalone/offline play
- `SERVER` and `PORT` — firo_runner_server endpoint for leaderboards
- Uses `http` package for API calls and `shared_preferences` for local caching

## Dependencies

| Package | Purpose |
|---------|---------|
| `flame` ^1.0.0-rc.11 | 2D game engine |
| `flame_audio` ^1.0.0-rc.1 | Game audio playback |
| `http` ^0.13.3 | HTTP client for tournament server |
| `qr_flutter` ^4.0.0 | QR code generation |
| `shared_preferences` ^2.0.8 | Local persistent storage |
| `cupertino_icons` ^1.0.2 | iOS-style icons |

**Dart SDK:** `>=2.12.0 <3.0.0` (null safety enabled)

## Linting

Uses `flutter_lints` (included via `analysis_options.yaml`). No custom rule overrides. Run `flutter analyze` to check for issues.

## Testing

Test files live in `test/`. Currently minimal coverage (placeholder widget test). Run with `flutter test`.

## Conventions

- **Constants:** SCREAMING_SNAKE_CASE (e.g., `LEVEL2`, `NO_TOURNAMENT`, `RUNNER_PRIORITY`)
- **Animation states:** Defined as enums per entity (e.g., `RunnerState`, `PlatformState`, `BugState`)
- **Sprite assets:** Organized by entity under `assets/images/<entity>/` with numbered frame files
- **Audio assets:** Background music in `assets/audio/`, sound effects in `assets/audio/sfx/`
- **Font:** Codystar (declared in `pubspec.yaml`)
- **No CI/CD pipelines** are configured — builds are done manually via Flutter CLI
