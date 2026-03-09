import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A SpriteAnimationGroupComponent that supports an optional biome color tint.
/// When [biomePaint] is set, it applies a color filter over the sprite
/// rendering to visually theme obstacles for different biomes.
///
/// Uses canvas saveLayer/restore to apply the tint as a post-processing step,
/// ensuring compatibility with all Flame versions.
class BiomeTintedSpriteAnimationGroupComponent<T>
    extends SpriteAnimationGroupComponent<T> {
  /// The paint used to apply a biome tint. If null, renders normally.
  Paint? biomePaint;

  BiomeTintedSpriteAnimationGroupComponent({
    required Map<T, SpriteAnimation> animations,
    T? current,
    this.biomePaint,
  }) : super(animations: animations, current: current);

  @override
  void render(Canvas canvas) {
    if (biomePaint != null) {
      // Use saveLayer to apply the tint paint as a color filter over the
      // entire sprite rendering. This works regardless of Flame's internal
      // Sprite.render() API.
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.x, size.y),
        biomePaint!,
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}
