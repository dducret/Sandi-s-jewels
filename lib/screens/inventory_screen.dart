import 'package:flutter/material.dart';
import 'package:sandi_s_jewels/widgets/resource_bar.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static const routeName = '/inventory';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Empire'),
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
                'Craft boosts, upgrade buildings, and prepare for tougher puzzles.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _InventorySection(
                title: 'Boosters',
                items: const [
                  _InventoryItem(
                    icon: Icons.bolt,
                    title: 'Lightning Charge',
                    detail: 'Smite a chosen tile and drop fresh resources.',
                  ),
                  _InventoryItem(
                    icon: Icons.grid_on,
                    title: 'Board Shuffle',
                    detail: 'Randomly rearrange the current grid.',
                  ),
                  _InventoryItem(
                    icon: Icons.auto_awesome,
                    title: 'Artifact Forge',
                    detail: 'Convert coins into relic tiles for combos.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InventorySection(
                title: 'Empire Upgrades',
                items: const [
                  _InventoryItem(
                    icon: Icons.water_drop,
                    title: 'Canal Repairs',
                    detail: 'Adds +1 move to water-based missions.',
                  ),
                  _InventoryItem(
                    icon: Icons.temple_hindu,
                    title: 'Shrine Focus',
                    detail: 'Starts levels with a pre-charged combo gem.',
                  ),
                  _InventoryItem(
                    icon: Icons.bakery_dining,
                    title: 'Marketplace',
                    detail: 'Earn 15% more coins for every clear.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({required this.title, required this.items});

  final String title;
  final List<_InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: item,
        )),
      ],
    );
  }
}

class _InventoryItem extends StatelessWidget {
  const _InventoryItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.white54),
        ],
      ),
    );
  }
}