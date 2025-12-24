import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CityBuilding extends SpriteComponent with HasGameRef {
  final String name;
  final int level;

  CityBuilding(this.name, this.level, Vector2 position) {
    this.position = position;
    size = Vector2(100, 100);
  }

  @override
  void render(Canvas canvas) {
    // Placeholder for building graphics
    final paint = Paint()..color = Colors.blueGrey;
    canvas.drawRect(size.toRect(), paint);

    TextPainter(
      text: TextSpan(text: name, style: const TextStyle(fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout()..paint(canvas, const Offset(10, 40));
  }
}

class CityMap extends World {
  @override
  Future<void> onLoad() async {
    // Place buildings in an isometric pattern
    add(CityBuilding("Market", 1, Vector2(150, 100)));
    add(CityBuilding("Granary", 1, Vector2(250, 150)));
    add(CityBuilding("Barracks", 1, Vector2(50, 150)));
  }
}