import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'cradle_game.dart';
import 'game_tile.dart'; // Needed for TileType enum
import 'level_data.dart';

// --- GameState and other classes from previous step would be here ---

void main() {
  runApp(const MaterialApp(home: MainNavigation()));
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool inGame = false;
  // Keep track of the game instance to read its progress for the UI
  CradleGame? _activeGame;

  void startLevel() {
    setState(() {
      inGame = true;
      // Create a new game instance with Level 1 data
      _activeGame = CradleGame(
        levelData: level1Config,
        onLevelComplete: handleLevelWon,
      );
    });
  }

  void handleLevelWon() {
    // 1. Here you would update the global GameState provider with rewards
    // context.read<GameState>().addResources(gold: 100);

    // 2. Show a "Victory" dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Level Complete!"),
        content: const Text("You collected the required resources."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Go back to city view
              setState(() { inGame = false; _activeGame = null; });
            },
            child: const Text("Back to City"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      body: Stack(
        children: [
          // State 1: City View Placeholder
          if (!inGame)
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("City Map View", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: startLevel,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text("Play Level 1 (Goal: 15 Gold)")
                    ),
                  ],
                )
            ),

          // State 2: The Game Container
          if (inGame && _activeGame != null)
            Center(
              child: Container(
                width: 480, height: 480,
                decoration: BoxDecoration(border: Border.all(color: Colors.amber, width: 4)),
                // Attach the specific game instance
                child: GameWidget(game: _activeGame!),
              ),
            ),

          // Game HUD overlay showing progress
          if (inGame && _activeGame != null)
            Positioned(
              top: 50, left: 0, right: 0,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _activeGame!.progressNotifier, // Listen to the game progress
                  builder: (context, progress, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Text(
                        "Goal: Collect Gold\nProgress: $progress / ${level1Config.targetAmount}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}
