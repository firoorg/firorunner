import 'package:flutter/material.dart';

/// The biome types the player progresses through as the game advances.
/// Each biome has a unique visual theme applied via color tinting.
enum Biome {
  city,
  grassland,
  forest,
  desert,
  tundra,
  utopia,
}

/// Configuration for each biome's visual and gameplay properties.
class BiomeConfig {
  /// Display name shown to the player.
  final String name;

  /// Tint color applied to the background.
  final Color backgroundTint;

  /// Tint color applied to platforms.
  final Color platformTint;

  /// Tint color applied to bug-type enemies.
  final Color bugTint;

  /// Tint color applied to wire/hazard obstacles.
  final Color wireTint;

  /// Tint color applied to debris obstacles.
  final Color debrisTint;

  /// Tint color applied to wall obstacles.
  final Color wallTint;

  /// Tint color applied to coins.
  final Color coinTint;

  /// Thematic name for bug-type enemies in this biome.
  final String bugName;

  /// Thematic name for wire-type hazards in this biome.
  final String wireName;

  /// Thematic name for debris obstacles in this biome.
  final String debrisName;

  /// Thematic name for wall obstacles in this biome.
  final String wallName;

  /// Overlay color drawn behind everything to set the atmosphere.
  final Color atmosphereColor;

  /// Opacity of the atmosphere overlay.
  final double atmosphereOpacity;

  const BiomeConfig({
    required this.name,
    required this.backgroundTint,
    required this.platformTint,
    required this.bugTint,
    required this.wireTint,
    required this.debrisTint,
    required this.wallTint,
    required this.coinTint,
    required this.bugName,
    required this.wireName,
    required this.debrisName,
    required this.wallName,
    required this.atmosphereColor,
    required this.atmosphereOpacity,
  });
}

/// All biome configurations, keyed by biome type.
const Map<Biome, BiomeConfig> biomeConfigs = {
  // Urban cityscape — the original look. No tinting, pure circuit aesthetic.
  Biome.city: BiomeConfig(
    name: "City",
    backgroundTint: Color(0xFFFFFFFF),
    platformTint: Color(0xFFFFFFFF),
    bugTint: Color(0xFFFFFFFF),
    wireTint: Color(0xFFFFFFFF),
    debrisTint: Color(0xFFFFFFFF),
    wallTint: Color(0xFFFFFFFF),
    coinTint: Color(0xFFFFFFFF),
    bugName: "Bug",
    wireName: "Wire",
    debrisName: "Debris",
    wallName: "Wall",
    atmosphereColor: Color(0xFF1a1a2e),
    atmosphereOpacity: 0.0,
  ),

  // Grassland — warm greens and earthy tones.
  Biome.grassland: BiomeConfig(
    name: "Grassland",
    backgroundTint: Color(0xFF7ec850),
    platformTint: Color(0xFF8B7355),
    bugTint: Color(0xFF55a630),
    wireTint: Color(0xFF6b8e23),
    debrisTint: Color(0xFF8B8378),
    wallTint: Color(0xFFA0926B),
    coinTint: Color(0xFFFFD700),
    bugName: "Grasshopper",
    wireName: "Thorns",
    debrisName: "Rocks",
    wallName: "Fence",
    atmosphereColor: Color(0xFF2d5a1e),
    atmosphereOpacity: 0.15,
  ),

  // Forest — deep greens and dark browns, dense atmosphere.
  Biome.forest: BiomeConfig(
    name: "Forest",
    backgroundTint: Color(0xFF2d5a27),
    platformTint: Color(0xFF5C4033),
    bugTint: Color(0xFF4a2040),
    wireTint: Color(0xFF2e8b57),
    debrisTint: Color(0xFF654321),
    wallTint: Color(0xFF5C4033),
    coinTint: Color(0xFFDAA520),
    bugName: "Spider",
    wireName: "Vines",
    debrisName: "Logs",
    wallName: "Fallen Tree",
    atmosphereColor: Color(0xFF0d260d),
    atmosphereOpacity: 0.25,
  ),

  // Desert — hot oranges, sandy yellows, dry reds.
  Biome.desert: BiomeConfig(
    name: "Desert",
    backgroundTint: Color(0xFFe8a53e),
    platformTint: Color(0xFFc2b280),
    bugTint: Color(0xFF8B0000),
    wireTint: Color(0xFF556B2F),
    debrisTint: Color(0xFFC19A6B),
    wallTint: Color(0xFFDEB887),
    coinTint: Color(0xFFFF8C00),
    bugName: "Scorpion",
    wireName: "Cactus Spines",
    debrisName: "Tumbleweeds",
    wallName: "Sandwall",
    atmosphereColor: Color(0xFF8B4513),
    atmosphereOpacity: 0.18,
  ),

  // Tundra — icy blues, whites, cold grays.
  Biome.tundra: BiomeConfig(
    name: "Tundra",
    backgroundTint: Color(0xFF87CEEB),
    platformTint: Color(0xFFB0C4DE),
    bugTint: Color(0xFF4682B4),
    wireTint: Color(0xFF00CED1),
    debrisTint: Color(0xFFD3D3D3),
    wallTint: Color(0xFFADD8E6),
    coinTint: Color(0xFFE0FFFF),
    bugName: "Ice Beetle",
    wireName: "Icicles",
    debrisName: "Snow Mounds",
    wallName: "Ice Wall",
    atmosphereColor: Color(0xFF1a3a5c),
    atmosphereOpacity: 0.20,
  ),

  // Futuristic Utopia Garden — vibrant neons, luminous purples and greens.
  Biome.utopia: BiomeConfig(
    name: "Utopia Garden",
    backgroundTint: Color(0xFF9b59b6),
    platformTint: Color(0xFF1abc9c),
    bugTint: Color(0xFFe74c3c),
    wireTint: Color(0xFF00ff88),
    debrisTint: Color(0xFF3498db),
    wallTint: Color(0xFF8e44ad),
    coinTint: Color(0xFFF1C40F),
    bugName: "Nano Drone",
    wireName: "Laser Grid",
    debrisName: "Holo Fragments",
    wallName: "Force Field",
    atmosphereColor: Color(0xFF1a0a2e),
    atmosphereOpacity: 0.15,
  ),
};

/// Returns the biome for a given game level.
Biome getBiomeForLevel(int level) {
  if (level <= 7) {
    return Biome.city;
  } else if (level <= 9) {
    return Biome.grassland;
  } else if (level <= 11) {
    return Biome.forest;
  } else if (level <= 13) {
    return Biome.desert;
  } else if (level <= 15) {
    return Biome.tundra;
  } else {
    return Biome.utopia;
  }
}

/// Returns the BiomeConfig for a given game level.
BiomeConfig getBiomeConfigForLevel(int level) {
  return biomeConfigs[getBiomeForLevel(level)]!;
}

/// Creates a Paint object with a color tint for rendering biome-themed sprites.
/// Uses srcATop blend mode to tint while preserving sprite transparency.
Paint biomeTintPaint(Color tintColor) {
  if (tintColor == const Color(0xFFFFFFFF)) {
    return Paint();
  }
  return Paint()
    ..colorFilter = ColorFilter.mode(
      tintColor.withOpacity(0.4),
      BlendMode.srcATop,
    );
}
