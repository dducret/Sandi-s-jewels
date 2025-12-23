import 'package:flutter/material.dart';
import 'package:sandi_s_jewels/models/game_models.dart';

class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.level});

  final LevelData level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLocked
            ? theme.canvasColor
            : theme.colorScheme.secondaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted
                ? Icons.verified
                : isLocked
                ? Icons.lock
                : Icons.local_fire_department,
            color: isLocked ? Colors.white60 : Colors.black,
          ),
          const SizedBox(width: 8),
          Text(
            'L${level.id}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isLocked ? Colors.white70 : Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            level.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isLocked ? Colors.white60 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}