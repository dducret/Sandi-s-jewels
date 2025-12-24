import 'game_tile.dart';

class LevelData {
  final int id;
  final TileType targetType;
  final int targetAmount;
  // You could add 'maxMoves' or 'timeLimit' here later

  LevelData({required this.id, required this.targetType, required this.targetAmount});
}

// A sample level configuration
final LevelData level1Config = LevelData(id: 1, targetType: TileType.gold, targetAmount: 15);