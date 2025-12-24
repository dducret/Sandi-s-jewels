import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'cradle_game.dart';

// Ensure these match your filenames exactly (e.g., gold.png)
enum TileType { gold, food, wood, stone }

class GameTile extends SpriteComponent with TapCallbacks, HasGameReference<CradleGame> {
  int gridX;
  int gridY;
  final TileType type;
  bool isSelected = false;

  GameTile(this.gridX, this.gridY, this.type);

  @override
  Future<void> onLoad() async {
    // 1. Load the sprite.
    // This assumes your files are at: assets/images/gems/gold.png, etc.
    // Note: Flame's loadSprite automatically looks in the 'assets/images/' folder.
    sprite = await game.loadSprite('gems/${type.name}.png');

    // 2. Set the visual size
    size = Vector2.all(CradleGame.tileSize - 4);

    // 3. Set the initial position based on the grid
    position = Vector2(
      gridX * CradleGame.tileSize + CradleGame.gridOffset,
      gridY * CradleGame.tileSize + CradleGame.gridOffset,
    );

    // 4. Set anchor to center to make animations (like scaling/rotating) look better
    anchor = Anchor.topLeft;
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleTileTap(this);
  }

  @override
  void render(Canvas canvas) {
    // This calls the SpriteComponent's internal render to draw the PNG
    super.render(canvas);

    // Draw the selection highlight overlay
    if (isSelected) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Draw a white border around the tile
      canvas.drawRect(size.toRect(), paint);
    }
  }
}