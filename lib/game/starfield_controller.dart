import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarfieldController {
  final List<Map<String, double>> stars = [];
  final int numberOfStars;
  final math.Random random = math.Random();
  final double starSpeed;
  final double starSize;

  StarfieldController({
    this.numberOfStars = 50,
    this.starSpeed = 0.5,
    this.starSize = 2.0,
  });

  void initStars(BuildContext context) {
    if (stars.isEmpty) {
      double screenWidth = MediaQuery.of(context).size.width;
      for (int i = 0; i < numberOfStars; i++) {
        stars.add({
          'x': random.nextDouble() * screenWidth,
          'y': random.nextDouble() * MediaQuery.of(context).size.height,
          'brightness': random.nextDouble(),
        });
      }
    }
  }

  void update(BuildContext context) {
    // Update stars
    for (var star in stars) {
      star['y'] = (star['y']! + starSpeed) % MediaQuery.of(context).size.height;
    }
  }

  void reset() {
    stars.clear();
  }
}
