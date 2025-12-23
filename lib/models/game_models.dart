import 'package:flutter/material.dart';

enum TileType { scarab, papyrus, crystal, potion, coin, relic }

extension TileTypeX on TileType {
  Color get color {
    switch (this) {
      case TileType.scarab:
        return const Color(0xFFE1C16E);
      case TileType.papyrus:
        return const Color(0xFF4FC3F7);
      case TileType.crystal:
        return const Color(0xFFB794F4);
      case TileType.potion:
        return const Color(0xFF8BC34A);
      case TileType.coin:
        return const Color(0xFFFFB74D);
      case TileType.relic:
        return const Color(0xFFEF5350);
    }
  }

  IconData get icon {
    switch (this) {
      case TileType.scarab:
        return Icons.bug_report;
      case TileType.papyrus:
        return Icons.menu_book;
      case TileType.crystal:
        return Icons.diamond;
      case TileType.potion:
        return Icons.local_drink;
      case TileType.coin:
        return Icons.monetization_on;
      case TileType.relic:
        return Icons.auto_fix_high;
    }
  }

  String get label {
    switch (this) {
      case TileType.scarab:
        return 'Scarab';
      case TileType.papyrus:
        return 'Papyrus';
      case TileType.crystal:
        return 'Crystal';
      case TileType.potion:
        return 'Potion';
      case TileType.coin:
        return 'Coin';
      case TileType.relic:
        return 'Relic';
    }
  }
}

class BoardPosition {
  const BoardPosition(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BoardPosition &&
              runtimeType == other.runtimeType &&
              row == other.row &&
              column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}

class SwapOutcome {
  const SwapOutcome({
    required this.matched,
    required this.cleared,
    required this.cascades,
    required this.largestMatch,
    required this.scoreAwarded,
  });

  final bool matched;
  final int cleared;
  final int cascades;
  final int largestMatch;
  final int scoreAwarded;
}

enum LevelStatus { locked, available, completed }

class Mission {
  const Mission({
    required this.name,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String name;
  final String detail;
  final IconData icon;
  final Color color;
}

class LevelData {
  const LevelData({
    required this.id,
    required this.title,
    required this.targetScore,
    required this.moves,
    required this.energyCost,
    required this.description,
    required this.missions,
    this.status = LevelStatus.available,
  });

  final int id;
  final String title;
  final int targetScore;
  final int moves;
  final int energyCost;
  final String description;
  final List<Mission> missions;
  final LevelStatus status;

  LevelData updateStatus(LevelStatus newStatus) => LevelData(
    id: id,
    title: title,
    targetScore: targetScore,
    moves: moves,
    energyCost: energyCost,
    description: description,
    missions: missions,
    status: newStatus,
  );
}