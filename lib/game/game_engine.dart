import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flame_audio/flame_audio.dart';

class GameEngine {
  // Movement properties
  double playerX = 0.0;
  double playerVelocity = 0.0;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  final double moveSpeed = 0.8; // Further reduced from 2.0 for slower control
  final double tapMoveDistance = 4.0; // Reduced from 10.0 for more precise movement
  final double maxVelocity = 3.0; // Further reduced from 6.0 for slower movement
  final double deceleration = 0.7; // Slightly faster deceleration

  // Game objects
  List<Offset> bullets = [];
  List<Offset> enemies = [];
  List<Offset> enemyVectors = [];
  final double enemySpeed = 1.0;
  int score = 0;
  double? screenWidth;
  int totalEnemiesSpawned = 0;
  final int maxEnemies = 10;
  bool gameCompleted = false;

  // Game area
  final double safeAreaPadding = 60.0;
  final double enemySize = 30.0;

  // Starfield
  final List<Map<String, double>> stars = [];
  final int numberOfStars = 50;
  final math.Random random = math.Random();
  final double starSpeed = 0.5;
  final double starSize = 2.0;

  // Callbacks
  final Function() onGameCompleted;

  GameEngine({required this.onGameCompleted});

  // Initialize starfield
  void initStars(BuildContext context) {
    if (stars.isEmpty) {
      screenWidth = MediaQuery.of(context).size.width;
      for (int i = 0; i < numberOfStars; i++) {
        stars.add({
          'x': random.nextDouble() * (screenWidth ?? 400),
          'y': random.nextDouble() * MediaQuery.of(context).size.height,
          'brightness': random.nextDouble(),
        });
      }
    }
  }

  // Game loop update function
  void update(BuildContext context) {
    // Update stars
    for (var star in stars) {
      star['y'] = (star['y']! + starSpeed) % MediaQuery.of(context).size.height;
    }

    // Update player movement
    if (isMovingLeft) {
      // Gradually accelerate up to max velocity for smooth movement
      playerVelocity = math.max(playerVelocity - 0.2, -maxVelocity); // Reduced acceleration from 0.5 to 0.2
    } else if (isMovingRight) {
      // Gradually accelerate up to max velocity for smooth movement
      playerVelocity = math.min(playerVelocity + 0.2, maxVelocity); // Reduced acceleration from 0.5 to 0.2
    } else {
      // Apply deceleration when not actively moving
      playerVelocity *= deceleration;
      // Stop completely when velocity is very small
      if (playerVelocity.abs() < 0.1) {
        playerVelocity = 0;
      }
    }

    // Update player position based on velocity
    if (playerVelocity != 0) {
      playerX = (playerX + playerVelocity).clamp(
        safeAreaPadding,
        MediaQuery.of(context).size.width - safeAreaPadding - 50.0,
      );
    }

    // Update bullets
    for (int i = bullets.length - 1; i >= 0; i--) {
      bullets[i] = Offset(bullets[i].dx, bullets[i].dy - 10.0);
      // Remove bullets that exit the safe area
      if (bullets[i].dy < safeAreaPadding ||
          bullets[i].dx < safeAreaPadding ||
          bullets[i].dx > (screenWidth ?? 300) - safeAreaPadding) {
        bullets.removeAt(i);
      }
    }

    // Update enemies
    for (int i = enemies.length - 1; i >= 0; i--) {
      enemies[i] = Offset(
        enemies[i].dx + enemyVectors[i].dx * enemySpeed,
        enemies[i].dy + enemyVectors[i].dy * enemySpeed,
      );

      // Bounce off safe area boundaries
      if (enemies[i].dx <= safeAreaPadding ||
          enemies[i].dx >= (screenWidth ?? 300) - safeAreaPadding - enemySize) {
        enemyVectors[i] = Offset(-enemyVectors[i].dx, enemyVectors[i].dy);
      }
      if (enemies[i].dy <= safeAreaPadding ||
          enemies[i].dy >=
              MediaQuery.of(context).size.height -
                  safeAreaPadding -
                  enemySize) {
        enemyVectors[i] = Offset(enemyVectors[i].dx, -enemyVectors[i].dy);
      }
    }

    // Check collisions
    for (int i = enemies.length - 1; i >= 0; i--) {
      for (int j = bullets.length - 1; j >= 0; j--) {
        if ((enemies[i].dx - bullets[j].dx).abs() < 20 &&
            (enemies[i].dy - bullets[j].dy).abs() < 20) {
          enemies.removeAt(i);
          enemyVectors.removeAt(i);
          bullets.removeAt(j);
          score += 10;
          FlameAudio.play('explosion.mp3', volume: 0.7);
          checkGameCompletion();
          break;
        }
      }
    }

    // Update player position based on velocity (again?)
    playerX += playerVelocity;

    // Clamp player position to safe area bounds
    playerX = playerX.clamp(
        safeAreaPadding, (screenWidth ?? 300) - safeAreaPadding - 50);

    // Decelerate player if not moving
    if (!isMovingLeft && !isMovingRight) {
      playerVelocity *= deceleration;
      if (playerVelocity.abs() < 0.1) playerVelocity = 0;
    }
  }

  void spawnEnemy(BuildContext context) {
    if (totalEnemiesSpawned >= maxEnemies) return;
    if (enemies.length >= 3) return;

    final random = math.Random();
    double availableWidth =
        (screenWidth ?? 300) - (safeAreaPadding * 2) - enemySize;
    double centerX = safeAreaPadding + random.nextDouble() * availableWidth;

    // Keep y-position within safe area's top portion
    double safeTopAreaHeight = MediaQuery.of(context).size.height * 0.3;
    double centerY = safeAreaPadding + random.nextDouble() * safeTopAreaHeight;

    enemies.add(Offset(centerX, centerY));
    totalEnemiesSpawned++;

    double angle = random.nextDouble() * 2 * math.pi;
    enemyVectors.add(Offset(math.cos(angle), math.sin(angle)));
  }

  void shoot(BuildContext context) {
    bullets.add(Offset(
      playerX + 25.0,
      MediaQuery.of(context).size.height - safeAreaPadding - 30.0,
    ));
    FlameAudio.play('shoot.mp3', volume: 0.5);
  }

  void checkGameCompletion() {
    if (totalEnemiesSpawned >= maxEnemies && enemies.isEmpty) {
      gameCompleted = true;
      onGameCompleted();
    }
  }

  void reset() {
    score = 0;
    enemies.clear();
    bullets.clear();
    enemyVectors.clear();
    totalEnemiesSpawned = 0;
    gameCompleted = false;

    // Reset stars
    stars.clear();
  }

  int getEnemiesKilled() {
    return score ~/ 10;
  }

  // Check if a position is within the safe area
  bool isWithinSafeArea(BuildContext context, Offset position) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return position.dx >= safeAreaPadding &&
        position.dx <= screenWidth - safeAreaPadding &&
        position.dy >= safeAreaPadding &&
        position.dy <= screenHeight - safeAreaPadding;
  }

  // Method to handle a single tap on directional controls
  void singleTapMove(bool isLeft) {
    if (isLeft) {
      // Move left by a small fixed amount
      playerX = math.max(playerX - tapMoveDistance, safeAreaPadding);
    } else {
      // Move right by a small fixed amount
      playerX = math.min(playerX + tapMoveDistance,
          (screenWidth ?? 400) - safeAreaPadding - 50.0);
    }
  }
}
