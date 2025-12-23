import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandi_s_jewels/screens/map_screen.dart';
import 'package:sandi_s_jewels/screens/inventory_screen.dart';
import 'package:sandi_s_jewels/state/game_state.dart';
import 'package:sandi_s_jewels/widgets/resource_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1035), Color(0xFF0D0B16)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ResourceBar(),
                  const SizedBox(height: 28),
                  Text(
                    'Cradle of Empires',
                    style: theme.textTheme.displaySmall?.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rebuild the empire through puzzles, city building, and daring expeditions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _HeroCard(
                    title: 'Story Campaign',
                    subtitle: 'Return to the ruins, rescue allies, and restore the empire.',
                    primaryAction: () =>
                        Navigator.of(context).pushNamed(MapScreen.routeName),
                    actionLabel: 'Continue',
                  ),
                  const SizedBox(height: 14),
                  _HeroCard(
                    title: 'Daily Trials',
                    subtitle: 'Boost energy, gather runes, and trigger combo shrines.',
                    actionLabel: 'View',
                    primaryAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Daily trials unlock after map level 2.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _MissionOverview(gameState: gameState),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(MapScreen.routeName),
                          icon: const Icon(Icons.map),
                          label: const Text('Explore Map'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: theme.colorScheme.outline),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(context).pushNamed(InventoryScreen.routeName),
                          icon: const Icon(Icons.backpack),
                          label: const Text('Inventory'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.actionLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback primaryAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: primaryAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _MissionOverview extends StatelessWidget {
  const _MissionOverview({required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryLevel = gameState.levels.first;
    final mission = primaryLevel.missions.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            mission.color.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: mission.color.withOpacity(0.6),
            child: Icon(mission.icon, color: Colors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Featured Mission', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(mission.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(mission.detail, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (gameState.energy / gameState.maxEnergy).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: mission.color,
                ),
                const SizedBox(height: 8),
                Text(
                  'Energy ready: ${gameState.energy}/${gameState.maxEnergy}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}