import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sandi_s_jewels/models/game_models.dart';

class MatchResult {
  MatchResult(this.groups);

  final List<Set<BoardPosition>> groups;

  bool get hasMatches => groups.isNotEmpty;

  int get cleared =>
      groups.fold(0, (previousValue, element) => previousValue + element.length);

  int get largest =>
      groups.fold(0, (previousValue, element) => max(previousValue, element.length));

  Set<BoardPosition> get flattened =>
      groups.fold(<BoardPosition>{}, (acc, group) => acc..addAll(group));
}

class GameBoard {
  GameBoard({
    this.rows = 7,
    this.columns = 7,
    Random? random,
  }) : _random = random ?? Random() {
    _generateBoard();
  }

  final int rows;
  final int columns;
  final Random _random;

  late List<List<TileType?>> _tiles;

  List<List<TileType?>> get tiles => _tiles;

  SwapOutcome swapAndResolve(BoardPosition first, BoardPosition second) {
    if (!_areAdjacent(first, second)) {
      return const SwapOutcome(
        matched: false,
        cleared: 0,
        cascades: 0,
        largestMatch: 0,
        scoreAwarded: 0,
      );
    }

    _swapTiles(first, second);
    var matches = _detectMatches();
    if (!matches.hasMatches) {
      _swapTiles(first, second);
      return const SwapOutcome(
        matched: false,
        cleared: 0,
        cascades: 0,
        largestMatch: 0,
        scoreAwarded: 0,
      );
    }

    int cleared = 0;
    int cascades = 0;
    int largestMatch = 0;

    while (matches.hasMatches) {
      cleared += matches.cleared;
      largestMatch = max(largestMatch, matches.largest);
      _clearMatches(matches);
      _collapseColumns();
      cascades++;
      matches = _detectMatches();
    }

    final scoreAwarded = _scoreForClear(cleared, cascades, largestMatch);
    return SwapOutcome(
      matched: true,
      cleared: cleared,
      cascades: cascades > 0 ? cascades - 1 : 0,
      largestMatch: largestMatch,
      scoreAwarded: scoreAwarded,
    );
  }

  void shuffleBoard() {
    _generateBoard();
  }

  bool _areAdjacent(BoardPosition a, BoardPosition b) {
    final rowDelta = (a.row - b.row).abs();
    final columnDelta = (a.column - b.column).abs();
    return (rowDelta == 1 && columnDelta == 0) ||
        (rowDelta == 0 && columnDelta == 1);
  }

  void _generateBoard() {
    _tiles = List.generate(
      rows,
          (_) => List.generate(columns, (_) => _randomTile()),
    );

    // Ensure the initial board does not start with pre-made matches.
    var matches = _detectMatches();
    int attempts = 0;
    while (matches.hasMatches && attempts < 30) {
      for (final position in matches.flattened) {
        _tiles[position.row][position.column] = _randomTile();
      }
      attempts++;
      matches = _detectMatches();
    }
  }

  TileType _randomTile() => TileType.values[_random.nextInt(TileType.values.length)];

  void _swapTiles(BoardPosition a, BoardPosition b) {
    final temp = _tiles[a.row][a.column];
    _tiles[a.row][a.column] = _tiles[b.row][b.column];
    _tiles[b.row][b.column] = temp;
  }

  MatchResult _detectMatches() {
    final groups = <Set<BoardPosition>>[];

    // Horizontal scan.
    for (int row = 0; row < rows; row++) {
      int runLength = 1;
      for (int col = 1; col < columns; col++) {
        final current = _tiles[row][col];
        final previous = _tiles[row][col - 1];
        if (current != null && current == previous) {
          runLength++;
        } else {
          if (runLength >= 3 && previous != null) {
            groups.add({
              for (int k = col - runLength; k < col; k++) BoardPosition(row, k),
            });
          }
          runLength = 1;
        }
      }
      if (runLength >= 3) {
        groups.add({
          for (int k = columns - runLength; k < columns; k++)
            BoardPosition(row, k),
        });
      }
    }

    // Vertical scan.
    for (int col = 0; col < columns; col++) {
      int runLength = 1;
      for (int row = 1; row < rows; row++) {
        final current = _tiles[row][col];
        final previous = _tiles[row - 1][col];
        if (current != null && current == previous) {
          runLength++;
        } else {
          if (runLength >= 3 && previous != null) {
            groups.add({
              for (int k = row - runLength; k < row; k++) BoardPosition(k, col),
            });
          }
          runLength = 1;
        }
      }
      if (runLength >= 3) {
        groups.add({
          for (int k = rows - runLength; k < rows; k++) BoardPosition(k, col),
        });
      }
    }

    return MatchResult(groups);
  }

  void _clearMatches(MatchResult matches) {
    for (final position in matches.flattened) {
      _tiles[position.row][position.column] = null;
    }
  }

  void _collapseColumns() {
    for (int col = 0; col < columns; col++) {
      final compacted = <TileType>[];
      for (int row = rows - 1; row >= 0; row--) {
        final tile = _tiles[row][col];
        if (tile != null) {
          compacted.add(tile);
        }
      }

      int row = rows - 1;
      for (final tile in compacted) {
        _tiles[row][col] = tile;
        row--;
      }
      while (row >= 0) {
        _tiles[row][col] = _randomTile();
        row--;
      }
    }
  }

  int _scoreForClear(int cleared, int cascades, int largestMatch) {
    if (cleared == 0) return 0;
    final comboBonus = max(0, cascades) * 10;
    final largeMatchBonus = max(0, largestMatch - 3) * 15;
    return cleared * 12 + comboBonus + largeMatchBonus;
  }
}

class GameSession {
  GameSession({
    required this.level,
    required this.board,
    required this.movesLeft,
    required this.score,
  });

  final LevelData level;
  final GameBoard board;
  int movesLeft;
  int score;
  bool completed = false;
  bool failed = false;
}

class GameState extends ChangeNotifier {
  GameState() {
    _levels = [
      LevelData(
        id: 1,
        title: 'Shattered Dunes',
        targetScore: 500,
        moves: 15,
        energyCost: 6,
        description: 'Restore the oasis crystals and awaken the ancient guardian.',
        missions: _coreMissions,
      ),
      LevelData(
        id: 2,
        title: 'Flooded Quarries',
        targetScore: 700,
        moves: 18,
        energyCost: 7,
        description: 'Drain the canals and rebuild the broken carts.',
        missions: _coreMissions.sublist(0, 2),
        status: LevelStatus.locked,
      ),
      LevelData(
        id: 3,
        title: 'Twilight Obelisk',
        targetScore: 950,
        moves: 20,
        energyCost: 7,
        description: 'Charge the obelisk runes before nightfall.',
        missions: _expandedMissions,
        status: LevelStatus.locked,
      ),
      LevelData(
        id: 4,
        title: 'Scribes\' Library',
        targetScore: 1200,
        moves: 22,
        energyCost: 8,
        description: 'Uncover the papyrus vault and rescue the archivist.',
        missions: _puzzleMissions,
        status: LevelStatus.locked,
      ),
      LevelData(
        id: 5,
        title: 'Sky Bazaar',
        targetScore: 1400,
        moves: 24,
        energyCost: 9,
        description: 'Refill merchant stocks to open the bazaar gates.',
        missions: _expandedMissions,
        status: LevelStatus.locked,
      ),
    ];
  }

  int energy = 28;
  int coins = 750;
  int crystals = 24;
  final int maxEnergy = 30;

  late List<LevelData> _levels;
  GameSession? activeSession;

  List<LevelData> get levels => _levels;

  bool startLevel(int levelId) {
    final level = _levels.firstWhere((lvl) => lvl.id == levelId);
    if (level.status == LevelStatus.locked) return false;
    if (energy < level.energyCost) return false;

    energy -= level.energyCost;
    activeSession = GameSession(
      level: level,
      board: GameBoard(),
      movesLeft: level.moves,
      score: 0,
    );
    notifyListeners();
    return true;
  }

  SwapOutcome? swap(BoardPosition first, BoardPosition second) {
    final session = activeSession;
    if (session == null) return null;
    if (session.completed || session.failed) return null;

    final outcome = session.board.swapAndResolve(first, second);
    if (!outcome.matched) {
      notifyListeners();
      return outcome;
    }

    session.movesLeft = max(0, session.movesLeft - 1);
    session.score += outcome.scoreAwarded;

    if (session.score >= session.level.targetScore) {
      _completeLevel(session);
    } else if (session.movesLeft == 0) {
      session.failed = true;
    }

    notifyListeners();
    return outcome;
  }

  void _completeLevel(GameSession session) {
    session.completed = true;
    coins += 120;
    crystals += 2;

    final currentIndex = _levels.indexWhere((level) => level.id == session.level.id);
    if (currentIndex + 1 < _levels.length &&
        _levels[currentIndex + 1].status == LevelStatus.locked) {
      _levels[currentIndex + 1] =
          _levels[currentIndex + 1].updateStatus(LevelStatus.available);
    }

    _levels[currentIndex] = _levels[currentIndex].updateStatus(LevelStatus.completed);
  }

  void abandonRun() {
    activeSession = null;
    notifyListeners();
  }

  void rechargeEnergy() {
    energy = maxEnergy;
    notifyListeners();
  }

  List<Mission> get _coreMissions => const [
    Mission(
      name: 'Gather Supplies',
      detail: 'Collect papyrus and relics to repair the workshop.',
      icon: Icons.inventory_2,
      color: Color(0xFF80CBC4),
    ),
    Mission(
      name: 'Rescue the Scout',
      detail: 'Break through crystal clusters to free the scout.',
      icon: Icons.directions_walk,
      color: Color(0xFFCE93D8),
    ),
    Mission(
      name: 'Empower the Shrine',
      detail: 'Charge the shrine by chaining combos.',
      icon: Icons.bolt,
      color: Color(0xFFFFF59D),
    ),
  ];

  List<Mission> get _expandedMissions => const [
    Mission(
      name: 'Restore the Canal',
      detail: 'Line up drops to refill the water basins.',
      icon: Icons.water_drop,
      color: Color(0xFF4FC3F7),
    ),
    Mission(
      name: 'Calm the Spirits',
      detail: 'Clear relic tiles to appease the ancient spirits.',
      icon: Icons.lightbulb_outline,
      color: Color(0xFFFFCC80),
    ),
    Mission(
      name: 'Build Trade Routes',
      detail: 'Match coins to open the merchant path.',
      icon: Icons.alt_route,
      color: Color(0xFFA5D6A7),
    ),
  ];

  List<Mission> get _puzzleMissions => const [
    Mission(
      name: 'Rewrite the Scrolls',
      detail: 'Complete matches near scroll tiles to scribe new routes.',
      icon: Icons.menu_book,
      color: Color(0xFF64B5F6),
    ),
    Mission(
      name: 'Light the Lanterns',
      detail: 'Chain together lantern tiles without breaking the flow.',
      icon: Icons.lightbulb,
      color: Color(0xFFFFE082),
    ),
    Mission(
      name: 'Protect the Archivist',
      detail: 'Clear scarab tiles to hold back the guardians.',
      icon: Icons.shield,
      color: Color(0xFFBA68C8),
    ),
  ];
}