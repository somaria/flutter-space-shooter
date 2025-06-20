import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int missedEnemies;
  final double safeAreaPadding;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.missedEnemies,
    required this.safeAreaPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: safeAreaPadding + 10,
      right: safeAreaPadding + 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Score: $score',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 5),
          Text(
            'Missed: $missedEnemies',
            style: const TextStyle(color: Colors.redAccent, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
