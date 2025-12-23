import 'package:flutter/material.dart';
import 'package:sandi_s_jewels/models/game_models.dart';
import 'package:sandi_s_jewels/widgets/tile_cell.dart';

class GameBoardView extends StatefulWidget {
  const GameBoardView({
    super.key,
    required this.tiles,
    required this.onSwap,
  });

  final List<List<TileType?>> tiles;
  final void Function(BoardPosition, BoardPosition) onSwap;

  @override
  State<GameBoardView> createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<GameBoardView> {
  BoardPosition? _selected;

  @override
  Widget build(BuildContext context) {
    final rows = widget.tiles.length;
    final columns = widget.tiles.first.length;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          gradient: const LinearGradient(
            colors: [Color(0xFF201A3C), Color(0xFF121026)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: rows * columns,
          itemBuilder: (context, index) {
            final row = index ~/ columns;
            final column = index % columns;
            final tile = widget.tiles[row][column];
            final pos = BoardPosition(row, column);
            return TileCell(
              tile: tile ?? TileType.coin,
              isSelected: _selected == pos,
              onTap: () => _handleTap(pos),
            );
          },
        ),
      ),
    );
  }

  void _handleTap(BoardPosition position) {
    if (_selected == null) {
      setState(() => _selected = position);
      return;
    }

    if (_selected == position) {
      setState(() => _selected = null);
      return;
    }

    if (!_areAdjacent(_selected!, position)) {
      setState(() => _selected = position);
      return;
    }

    widget.onSwap(_selected!, position);
    setState(() => _selected = null);
  }

  bool _areAdjacent(BoardPosition a, BoardPosition b) {
    final rowDelta = (a.row - b.row).abs();
    final columnDelta = (a.column - b.column).abs();
    return (rowDelta == 1 && columnDelta == 0) ||
        (rowDelta == 0 && columnDelta == 1);
  }
}