import 'package:flutter/material.dart';
import 'package:sandi_s_jewels/models/game_models.dart';

class MissionCardList extends StatelessWidget {
  const MissionCardList({super.key, required this.missions});

  final List<Mission> missions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final mission in missions) ...[
          _MissionCard(mission: mission),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: mission.color.withOpacity(0.75),
            child: Icon(mission.icon, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  mission.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}