import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flame_audio/flame_audio.dart';

class EnemyController {
  List<Offset> enemies = [];
  List<Offset> enemyVectors = [];
  final double enemySpeed;
  final double enemySize;
  final double safeAreaPadding;
  int totalEnemiesSpawned = 0;
  final int maxEnemies;
  int missedEnemies = 0;

  EnemyController({
    this.enemySpeed = 1.0,
    this.enemySize = 30.0,
    required this.safeAreaPadding,
    this.maxEnemies = 10,
  });

  void update(BuildContext context) {
    // Update enemies
    for (int i = enemies.length - 1; i >= 0; i--) {
      enemies[i] = Offset(
        enemies[i].dx + enemyVectors[i].dx * enemySpeed,
        enemies[i].dy + enemyVectors[i].dy * enemySpeed,
      );

      // Bounce off safe area boundaries
      if (enemies[i].dx <= safeAreaPadding ||
          enemies[i].dx >=
              MediaQuery.of(context).size.width - safeAreaPadding - enemySize) {
        enemyVectors[i] = Offset(-enemyVectors[i].dx, enemyVectors[i].dy);
      }

      // Only bounce off the top boundary, not the bottom
      if (enemies[i].dy <= safeAreaPadding) {
        enemyVectors[i] = Offset(enemyVectors[i].dx, -enemyVectors[i].dy);
      }

      // Check if enemy is approaching the bottom boundary
      double playerYPosition =
          MediaQuery.of(context).size.height - safeAreaPadding;
      if (enemies[i].dy >= playerYPosition - 30) {
        // If enemy is moving downward (positive dy), count as missed when it reaches player level
        if (enemyVectors[i].dy > 0) {
          // Enemy missed - remove it and increment counter
          enemies.removeAt(i);
          enemyVectors.removeAt(i);
          missedEnemies++;
          continue;
        }
      }
    }
  }

  bool checkCollisionWithBullet(int enemyIndex, Offset bulletPosition) {
    if ((enemies[enemyIndex].dx - bulletPosition.dx).abs() < 20 &&
        (enemies[enemyIndex].dy - bulletPosition.dy).abs() < 20) {
      return true;
    }
    return false;
  }

  void spawnEnemy(BuildContext context) {
    if (totalEnemiesSpawned >= maxEnemies) return;
    if (enemies.length >= 3) return; // Max 3 enemies at a time

    final random = math.Random();
    double availableWidth =
        MediaQuery.of(context).size.width - (safeAreaPadding * 2) - enemySize;
    double centerX = safeAreaPadding + random.nextDouble() * availableWidth;

    // Keep y-position within safe area's top portion
    double safeTopAreaHeight = MediaQuery.of(context).size.height * 0.3;
    double centerY = safeAreaPadding + random.nextDouble() * safeTopAreaHeight;

    enemies.add(Offset(centerX, centerY));
    totalEnemiesSpawned++;

    double angle = random.nextDouble() * 2 * math.pi;
    enemyVectors.add(Offset(math.cos(angle), math.sin(angle)));
  }

  void removeEnemy(int index) {
    enemies.removeAt(index);
    enemyVectors.removeAt(index);
  }

  void reset() {
    enemies.clear();
    enemyVectors.clear();
    totalEnemiesSpawned = 0;
    missedEnemies = 0;
  }

  bool isCompleted() {
    return totalEnemiesSpawned >= maxEnemies && enemies.isEmpty;
  }
}
