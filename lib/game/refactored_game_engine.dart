import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'player_controller.dart';
import 'bullet_controller.dart';
import 'enemy_controller.dart';
import 'starfield_controller.dart';

class GameEngine {
  // Game area
  final double safeAreaPadding;
  final double enemySize;

  // Controllers
  late final PlayerController playerController;
  late final BulletController bulletController;
  late final EnemyController enemyController;
  late final StarfieldController starfieldController;

  // Game state
  int score = 0;
  bool gameCompleted = false;

  // Constructor
  GameEngine({
    this.safeAreaPadding = 20.0,
    this.enemySize = 30.0,
    double bulletSpeed =
        5.0, // Default bullet speed is now 5.0 (50% of original speed)
  }) {
    playerController = PlayerController(safeAreaPadding: safeAreaPadding);
    bulletController = BulletController(
      safeAreaPadding: safeAreaPadding,
      bulletSpeed: bulletSpeed,
    );
    enemyController = EnemyController(
      safeAreaPadding: safeAreaPadding,
      enemySize: enemySize,
    );
    starfieldController = StarfieldController();
  }

  // Accessors for game state
  double get playerX => playerController.playerX;
  set playerX(double value) => playerController.playerX = value;

  double get playerVelocity => playerController.playerVelocity;
  set playerVelocity(double value) => playerController.playerVelocity = value;

  bool get isMovingLeft => playerController.isMovingLeft;
  set isMovingLeft(bool value) => playerController.isMovingLeft = value;

  bool get isMovingRight => playerController.isMovingRight;
  set isMovingRight(bool value) => playerController.isMovingRight = value;

  List<Offset> get bullets => bulletController.bullets;
  List<Offset> get enemies => enemyController.enemies;
  List<Map<String, double>> get stars => starfieldController.stars;
  int get totalEnemiesSpawned => enemyController.totalEnemiesSpawned;
  int get maxEnemies => enemyController.maxEnemies;
  int get missedEnemies => enemyController.missedEnemies;
  double get starSize => starfieldController.starSize;

  // Game loop update function
  void update(BuildContext context) {
    playerController.update(context);
    bulletController.update();
    enemyController.update(context);
    starfieldController.update(context);

    checkCollisions();
  }

  // Collision detection
  void checkCollisions() {
    // Check for bullet-enemy collisions
    for (int i = bullets.length - 1; i >= 0; i--) {
      for (int j = enemies.length - 1; j >= 0; j--) {
        if (enemyController.checkCollisionWithBullet(j, bullets[i])) {
          // Collision detected
          bullets.removeAt(i);
          enemyController.removeEnemy(j);
          score++;
          FlameAudio.play('explosion.mp3');
          break;
        }
      }
    }

    // Check if game is completed
    gameCompleted = enemyController.isCompleted();
  }

  // Player shoots a bullet
  void shoot(BuildContext context) {
    bulletController.shoot(context, playerX);
  }

  // Spawns enemies
  void spawnEnemy(BuildContext context) {
    enemyController.spawnEnemy(context);
  }

  // Initialize stars for the starfield
  void initStars(BuildContext context) {
    starfieldController.initStars(context);
  }

  // Reset game state
  void reset() {
    score = 0;
    gameCompleted = false;

    playerController.reset();
    bulletController.reset();
    enemyController.reset();
    starfieldController.reset();
  }

  // Handle single tap movements
  void singleTapLeft(double? screenWidth) {
    playerController.singleTapMove(true, screenWidth);
  }

  void singleTapRight(double? screenWidth) {
    playerController.singleTapMove(false, screenWidth);
  }
}
