import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import 'player.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'starfield.dart';
import 'score_display.dart';

class GameArea extends StatelessWidget {
  final GameEngine gameEngine;

  const GameArea({
    super.key,
    required this.gameEngine,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.blue, width: 4.0),
        ),
        child: Stack(
          children: [
            // Starfield background
            StarfieldWidget(
                stars: gameEngine.stars, starSize: gameEngine.starSize),

            // Safe area visualization
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(gameEngine.safeAreaPadding),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Player
            PlayerWidget(
              playerX: gameEngine.playerX,
              playerY: gameEngine.safeAreaPadding,
            ),

            // Bullets
            ...gameEngine.bullets.map(
              (bullet) => BulletWidget(position: bullet),
            ),

            // Enemies
            ...gameEngine.enemies.map(
              (enemy) =>
                  EnemyWidget(position: enemy, size: gameEngine.enemySize),
            ),

            // Score and missed enemies display
            ScoreDisplay(
              score: gameEngine.score,
              missedEnemies: gameEngine.missedEnemies,
              safeAreaPadding: gameEngine.safeAreaPadding,
            ),
          ],
        ),
      ),
    );
  }
}
