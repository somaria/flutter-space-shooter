import 'package:flutter/material.dart';
import '../database_helper.dart';

class GameCompletionDialog extends StatelessWidget {
  final int score;
  final int enemiesDefeated;
  final int enemiesMissed;
  final VoidCallback onBackToMenu;
  final VoidCallback? onPlayAgain;

  const GameCompletionDialog({
    super.key,
    required this.score,
    required this.enemiesDefeated,
    this.enemiesMissed = 0,
    required this.onBackToMenu,
    this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    // Save the score
    _saveScore();

    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.blue, width: 2),
      ),
      title: const Text(
        'Game Completed!',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Congratulations!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Your Score: $score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enemies Defeated: $enemiesDefeated',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Enemies Missed: $enemiesMissed',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onBackToMenu();
          },
          child: const Text('Back to Menu'),
        ),
        if (onPlayAgain != null)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onPlayAgain!();
            },
            child: const Text('Play Again'),
          ),
      ],
    );
  }

  Future<void> _saveScore() async {
    await DatabaseHelper.instance.insertScore(score, enemiesDefeated);
  }
}
