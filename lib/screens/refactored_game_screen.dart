import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../game/refactored_game_engine.dart';
import '../widgets/control_buttons.dart';
import '../widgets/refactored_game_area.dart';
import '../widgets/game_completion_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late GameEngine _gameEngine;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();

    // Create game engine
    _gameEngine = GameEngine();

    // Create animation controller for game loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Add listener to animation controller for game loop
    _controller.addListener(_gameLoop);
    _controller.repeat();

    // Initialize game state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameEngine.initStars(context);
      _spawnEnemies();
    });
  }

  // Game loop
  void _gameLoop() {
    setState(() {
      _gameEngine.update(context);

      if (_gameEngine.gameCompleted) {
        _controller.stop();
        _showGameCompletionDialog();
      }
    });
  }

  // Show game completion dialog
  void _showGameCompletionDialog() {
    // Save game result to database
    _databaseHelper.insertScore(
      _gameEngine.score,
      _gameEngine.score, // enemiesDefeated equals score
      _gameEngine.missedEnemies,
    );

    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameCompletionDialog(
          score: _gameEngine.score,
          enemiesDefeated: _gameEngine.score,
          enemiesMissed: _gameEngine.missedEnemies,
          onPlayAgain: _resetGame,
          onBackToMenu: () => Navigator.pop(context),
        );
      },
    );
  }

  // Spawn enemies periodically
  void _spawnEnemies() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_gameEngine.gameCompleted) {
        setState(() {
          _gameEngine.spawnEnemy(context);
        });
        _spawnEnemies(); // Schedule next spawn
      }
    });
  }

  // Reset game
  void _resetGame() {
    setState(() {
      _gameEngine.reset();
      // Reinitialize stars
      _gameEngine.initStars(context);
    });

    // Restart the animation controller
    _controller.repeat();
    _spawnEnemies();
  }

  // Player shoots
  void _shoot() {
    setState(() {
      _gameEngine.shoot(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Use SafeArea but exclude bottom since we handle that separately in ControlButtons
        bottom: false,
        child: Column(
          children: [
            // Game Area
            RefactoredGameArea(gameEngine: _gameEngine),

            // Control buttons
            ControlButtons(
              onShoot: _shoot,
              onMoveLeft: (isMoving) {
                setState(() {
                  _gameEngine.isMovingLeft = isMoving;
                });
              },
              onMoveRight: (isMoving) {
                setState(() {
                  _gameEngine.isMovingRight = isMoving;
                });
              },
              onSingleTapLeft: () {
                setState(() {
                  _gameEngine.singleTapLeft(MediaQuery.of(context).size.width);
                });
              },
              onSingleTapRight: () {
                setState(() {
                  _gameEngine.singleTapRight(MediaQuery.of(context).size.width);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
