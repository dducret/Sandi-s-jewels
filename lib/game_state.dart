import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  int gold = 100;
  int wood = 50;
  int food = 50;

  void addResources({int? g, int? w, int? f}) {
    gold += g ?? 0;
    wood += w ?? 0;
    food += f ?? 0;
    notifyListeners(); // Updates the UI automatically
  }

  bool canAfford(int g, int w, int f) {
    return gold >= g && wood >= w && food >= f;
  }

  void spendResources(int g, int w, int f) {
    gold -= g;
    wood -= w;
    food -= f;
    notifyListeners();
  }
}