import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:flutter/material.dart'; // Needed for VoidCallback
import 'game_tile.dart';
import 'level_data.dart';

class CradleGame extends FlameGame {
  // --- Config constants remain the same ---
  static const double tileSize = 45.0;
  static const double gridOffset = 60.0;
  final int rows = 8;
  final int cols = 8;
  final ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  late List<List<GameTile?>> grid;
  GameTile? selectedTile;

  // --- NEW LEVEL LOGIC ---
  final LevelData levelData;
  int currentProgress = 0;
  final VoidCallback onLevelComplete; // A function to call when we win

  CradleGame({required this.levelData, required this.onLevelComplete});

  @override
  Future<void> onLoad() async {
    grid = List.generate(rows, (y) => List.generate(cols, (x) => null));
    _setupGrid();
  }

  void _setupGrid() {
    final random = Random();
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        _spawnTile(x, y, random);
      }
    }
  }

  void _spawnTile(int x, int y, Random random, {bool fromTop = false}) {
    final type = TileType.values[random.nextInt(TileType.values.length)];
    final tile = GameTile(x, y, type);

    if (fromTop) {
      // Start above the screen for "falling" effect
      tile.position.y = -tileSize;
      tile.add(MoveEffect.to(
        Vector2(x * tileSize + gridOffset, y * tileSize + gridOffset),
        EffectController(duration: 0.4),
      ));
    }

    grid[y][x] = tile;
    add(tile);
  }

  void handleTileTap(GameTile tappedTile) {
    if (selectedTile == null) {
      selectedTile = tappedTile;
      tappedTile.isSelected = true;
    } else {
      if (_isNeighbor(selectedTile!, tappedTile)) {
        _swapTiles(selectedTile!, tappedTile);
      }
      selectedTile!.isSelected = false;
      selectedTile = null;
    }
  }

  bool _isNeighbor(GameTile t1, GameTile t2) {
    return (t1.gridX - t2.gridX).abs() + (t1.gridY - t2.gridY).abs() == 1;
  }

  void _swapTiles(GameTile t1, GameTile t2) async {
    // Swap in logical grid
    int t1X = t1.gridX; int t1Y = t1.gridY;
    grid[t1Y][t1X] = t2;
    grid[t2.gridY][t2.gridX] = t1;

    // Update coordinates
    t1.gridX = t2.gridX; t1.gridY = t2.gridY;
    t2.gridX = t1X; t2.gridY = t1Y;

    // Visual animation
    t1.add(MoveEffect.to(t2.position.clone(), EffectController(duration: 0.2)));
    t2.add(MoveEffect.to(t1.position.clone(), EffectController(duration: 0.2)));

    // Wait for animation, then check matches
    Future.delayed(const Duration(milliseconds: 250), () => _processBoard());
  }

  // --- UPDATED: Track progress when tiles are cleared ---
  void _processBoard() {
    final matches = _findMatches();
    if (matches.isNotEmpty) {
      for (var tile in matches) {
        if (tile.type == levelData.targetType) {
          // UPDATE: Increment the notifier value
          progressNotifier.value++;
        }
        grid[tile.gridY][tile.gridX] = null;
        tile.removeFromParent();
      }
      _applyGravity();
      _checkWinCondition();
    }
  }

  void _checkWinCondition() {
    // UPDATE: Check the .value property
    if (progressNotifier.value >= levelData.targetAmount) {
      pauseEngine();
      onLevelComplete();
    }
  }

  Set<GameTile> _findMatches() {
    Set<GameTile> matches = {};
    // Horizontal
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols - 2; x++) {
        var t1 = grid[y][x], t2 = grid[y][x+1], t3 = grid[y][x+2];
        if (t1 != null && t2 != null && t3 != null && t1.type == t2.type && t2.type == t3.type) {
          matches.addAll([t1, t2, t3]);
        }
      }
    }
    // Vertical
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows - 2; y++) {
        var t1 = grid[y][x], t2 = grid[y+1][x], t3 = grid[y+2][x];
        if (t1 != null && t2 != null && t3 != null && t1.type == t2.type && t2.type == t3.type) {
          matches.addAll([t1, t2, t3]);
        }
      }
    }
    return matches;
  }

  void _applyGravity() {
    final random = Random();
    for (int x = 0; x < cols; x++) {
      int emptySpaces = 0;
      for (int y = rows - 1; y >= 0; y--) {
        if (grid[y][x] == null) {
          emptySpaces++;
        } else if (emptySpaces > 0) {
          var tile = grid[y][x]!;
          grid[y + emptySpaces][x] = tile;
          grid[y][x] = null;
          tile.gridY += emptySpaces;
          tile.add(MoveEffect.to(
            Vector2(x * tileSize + gridOffset, tile.gridY * tileSize + gridOffset),
            EffectController(duration: 0.3),
          ));
        }
      }
      // Refill from top
      for (int i = 0; i < emptySpaces; i++) {
        _spawnTile(x, i, random, fromTop: true);
      }
    }
    // Recursive check for new matches after gravity
    Future.delayed(const Duration(milliseconds: 400), () => _processBoard());
  }
}