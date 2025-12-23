import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandi_s_jewels/models/game_models.dart';
import 'package:sandi_s_jewels/state/game_state.dart';
import 'package:sandi_s_jewels/widgets/game_board.dart';
import 'package:sandi_s_jewels/widgets/resource_bar.dart';
import 'package:sandi_s_jewels/widgets/stat_chip.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String _statusMessage = 'Swap tiles to start rebuilding.';
  SwapOutcome? _lastOutcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<GameState>().activeSession;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Level not started')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose a level from the map to begin.'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.map),
                label: const Text('Back to map'),
              ),
            ],
          ),
        ),
      );
    }

    final progress =
    (session.score / session.level.targetScore).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(session.level.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Abandon run',
            onPressed: () {
              context.read<GameState>().abandonRun();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ResourceBar(),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatChip(
                          label: 'Score',
                          value: '${session.score}/${session.level.targetScore}',
                          icon: Icons.emoji_events,
                        ),
                        const SizedBox(width: 10),
                        StatChip(
                          label: 'Moves',
                          value: '${session.movesLeft}',
                          icon: Icons.swap_vert_circle,
                        ),
                        const SizedBox(width: 10),
                        StatChip(
                          label: 'Goal',
                          value: session.level.missions.first.name,
                          icon: Icons.bolt,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: theme.colorScheme.secondaryContainer,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GameBoardView(
                tiles: session.board.tiles,
                onSwap: (first, second) => _handleSwap(first, second),
              ),
              const SizedBox(height: 14),
              _OutcomeRow(outcome: _lastOutcome),
              const SizedBox(height: 12),
              _BoosterRow(),
              const SizedBox(height: 24),
              _VictoryBanner(session: session),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSwap(BoardPosition first, BoardPosition second) {
    final gameState = context.read<GameState>();
    final outcome = gameState.swap(first, second);
    final session = gameState.activeSession;

    if (!mounted) return;

    setState(() {
      _lastOutcome = outcome;
      if (outcome == null) {
        _statusMessage = 'No active run. Choose a level from the map.';
      } else if (!outcome.matched) {
        _statusMessage = 'Swap failed. Try adjacent tiles with potential matches.';
      } else {
        _statusMessage =
        'Cleared ${outcome.cleared} tiles with ${outcome.cascades} cascades!';
      }
    });

    if (session == null) return;

    if (session.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level complete! Rewards added to your empire.'),
        ),
      );
    } else if (session.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Out of moves. Try again or replay earlier stages.'),
        ),
      );
    }
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({this.outcome});

  final SwapOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (outcome == null) {
      return Text(
        'Tips: create crosses for cascades and prioritize mission colors.',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
      );
    }

    if (!outcome!.matched) {
      return Text(
        'Those tiles cannot combine. Look for a line of three or more.',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.orangeAccent),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.stars, color: Colors.black),
          label: Text('Cleared ${outcome!.cleared}'),
          backgroundColor: theme.colorScheme.secondaryContainer,
        ),
        Chip(
          avatar: const Icon(Icons.auto_awesome, color: Colors.black),
          label: Text('Cascades ${outcome!.cascades}'),
          backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
        ),
        Chip(
          avatar: const Icon(Icons.shield, color: Colors.black),
          label: Text('Score +${outcome!.scoreAwarded}'),
          backgroundColor: Colors.amberAccent,
        ),
      ],
    );
  }
}

class _BoosterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boosters', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: const [
            _BoosterChip(
              icon: Icons.bolt,
              label: 'Smite',
              description: 'Remove a chosen tile.',
            ),
            _BoosterChip(
              icon: Icons.shuffle,
              label: 'Shuffle',
              description: 'Reroll the current board.',
            ),
            _BoosterChip(
              icon: Icons.auto_fix_high,
              label: 'Craft',
              description: 'Upgrade relic tiles this turn.',
            ),
          ],
        ),
      ],
    );
  }
}

class _BoosterChip extends StatelessWidget {
  const _BoosterChip({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      padding: const EdgeInsets.all(8),
      avatar: Icon(icon, color: Colors.black),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
          Text(
            description,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.black87),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
    );
  }
}

class _VictoryBanner extends StatelessWidget {
  const _VictoryBanner({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (session.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.greenAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Victory!', style: theme.textTheme.titleLarge),
            Text(
              'Loot delivered to the empire. Replay for more coins and crystals.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (session.failed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Out of moves', style: theme.textTheme.titleLarge),
            Text(
              'Reshuffle and try again to rescue the district.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}