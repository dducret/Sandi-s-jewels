import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandi_s_jewels/models/game_models.dart';
import 'package:sandi_s_jewels/screens/game_screen.dart';
import 'package:sandi_s_jewels/state/game_state.dart';
import 'package:sandi_s_jewels/widgets/level_chip.dart';
import 'package:sandi_s_jewels/widgets/mission_card.dart';
import 'package:sandi_s_jewels/widgets/resource_bar.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const routeName = '/map';

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final levels = gameState.levels;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empire Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameState>().rechargeEnergy(),
            tooltip: 'Refill energy for previews',
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
              Text(
                'Choose a district to restore. Each victory reveals more of the empire.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: levels.map((level) => LevelChip(level: level)).toList(),
              ),
              const SizedBox(height: 20),
              for (final level in levels) ...[
                _LevelCard(level: level),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final LevelData level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = context.watch<GameState>();
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;
    final subtitle = level.description;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.white12 : theme.colorScheme.secondaryContainer,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isLocked
                    ? Colors.grey.shade800
                    : theme.colorScheme.secondaryContainer.withOpacity(0.8),
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isLocked
                      ? Icons.lock
                      : Icons.shield,
                  color: isLocked ? Colors.white54 : Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Moves: ${level.moves}', style: theme.textTheme.bodySmall),
                  Text('Target: ${level.targetScore}', style: theme.textTheme.bodySmall),
                  Text('Energy: ${level.energyCost}', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          MissionCardList(missions: level.missions),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLocked
                  ? null
                  : () {
                final started = context.read<GameState>().startLevel(level.id);
                if (!started) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not enough energy. Recharge or finish a mission.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushNamed(GameScreen.routeName);
              },
              icon: Icon(isCompleted ? Icons.replay : Icons.play_arrow),
              label: Text(isCompleted ? 'Replay for rewards' : 'Start level'),
            ),
          ),
        ],
      ),
    );
  }
}