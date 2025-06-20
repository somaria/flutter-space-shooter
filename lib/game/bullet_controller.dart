import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class BulletController {
  List<Offset> bullets = [];
  final double safeAreaPadding;
  final double bulletSpeed;

  BulletController({
    required this.safeAreaPadding,
    this.bulletSpeed = 5.0, // Default is now 5.0 (50% of original speed)
  });

  void update() {
    // Update bullets
    for (int i = bullets.length - 1; i >= 0; i--) {
      bullets[i] = Offset(bullets[i].dx, bullets[i].dy - bulletSpeed);
      // Remove bullets that exit the safe area
      if (bullets[i].dy < safeAreaPadding ||
          bullets[i].dx < safeAreaPadding ||
          bullets[i].dx > 10000 - safeAreaPadding) {
        // Use a large value as fallback
        bullets.removeAt(i);
      }
    }
  }

  void shoot(BuildContext context, double playerX) {
    bullets.add(Offset(
      playerX + 25.0,
      MediaQuery.of(context).size.height - safeAreaPadding - 30.0,
    ));
    FlameAudio.play('shoot.mp3', volume: 0.5);
  }

  void reset() {
    bullets.clear();
  }
}
