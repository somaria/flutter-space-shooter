import 'package:flutter/material.dart';
import 'dart:math' as math;

class PlayerController {
  // Movement properties
  double playerX = 0.0;
  double playerVelocity = 0.0;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  final double moveSpeed = 0.4;
  final double tapMoveDistance = 2.0;
  final double maxVelocity = 1.5;
  final double deceleration = 0.7;

  // Safe area padding
  final double safeAreaPadding;

  PlayerController({required this.safeAreaPadding});

  void update(BuildContext context) {
    // Update player movement
    if (isMovingLeft) {
      // Gradually accelerate up to max velocity for smooth movement
      playerVelocity = math.max(playerVelocity - 0.1, -maxVelocity);
    } else if (isMovingRight) {
      // Gradually accelerate up to max velocity for smooth movement
      playerVelocity = math.min(playerVelocity + 0.1, maxVelocity);
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
  }

  // Method to handle a single tap on directional controls
  void singleTapMove(bool isLeft, double? screenWidth) {
    if (isLeft) {
      // Move left by a small fixed amount
      playerX = math.max(playerX - tapMoveDistance, safeAreaPadding);
    } else {
      // Move right by a small fixed amount
      playerX = math.min(playerX + tapMoveDistance,
          (screenWidth ?? 400) - safeAreaPadding - 50.0);
    }
  }

  void reset() {
    playerX = 0.0;
    playerVelocity = 0.0;
    isMovingLeft = false;
    isMovingRight = false;
  }
}
