import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../database_helper.dart';
import '../game/game_engine.dart';
import '../widgets/control_buttons.dart';
import '../widgets/player.dart';
import '../widgets/enemy.dart';
import '../widgets/bullet.dart';
import '../widgets/starfield.dart';
import '../widgets/game_completion_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late GameEngine _gameEngine;

  @override
  void initState() {
    super.initState();
    // Create game engine
    _gameEngine = GameEngine(
      onGameCompleted: _showGameCompletionDialog,
    );

    // Preload audio files
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.loadAll(['shoot.mp3', 'explosion.mp3']);

    // Set up game loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..addListener(_gameLoop);
    _controller.repeat();

    // Start enemy spawning after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnEnemies();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize stars
    _gameEngine.initStars(context);
  }

  void _gameLoop() {
    setState(() {
      _gameEngine.update(context);
    });
  }

  void _spawnEnemies() {
    if (!mounted || _gameEngine.gameCompleted) return;

    setState(() {
      _gameEngine.spawnEnemy(context);
    });

    if (_gameEngine.totalEnemiesSpawned < _gameEngine.maxEnemies) {
      Future.delayed(const Duration(seconds: 4), _spawnEnemies);
    }
  }

  Future<void> _showGameCompletionDialog() async {
    _controller.stop();

    int score = _gameEngine.score;
    int enemiesKilled = _gameEngine.getEnemiesKilled();
    int missedEnemies = _gameEngine.getMissedEnemies();

    // Save the score to the database
    await DatabaseHelper.instance
        .insertScore(score, enemiesKilled, missedEnemies);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompletionDialog(
        score: score,
        enemiesDefeated: enemiesKilled,
        enemiesMissed: missedEnemies,
        onBackToMenu: () {
          Navigator.of(context).pop(); // Return to home screen
        },
        onPlayAgain: _resetGame,
      ),
    );
  }

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
            // Game Area - takes most of the screen
            Expanded(
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
                        stars: _gameEngine.stars,
                        starSize: _gameEngine.starSize),

                    // Safe area visualization
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.all(_gameEngine.safeAreaPadding),
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
                      playerX: _gameEngine.playerX,
                      playerY: _gameEngine.safeAreaPadding,
                    ),

                    // Bullets
                    ..._gameEngine.bullets.map(
                      (bullet) => BulletWidget(position: bullet),
                    ),

                    // Enemies
                    ..._gameEngine.enemies.map(
                      (enemy) => EnemyWidget(
                          position: enemy, size: _gameEngine.enemySize),
                    ),

                    // Score and Missed Count
                    Positioned(
                      top: _gameEngine.safeAreaPadding + 10,
                      right: _gameEngine.safeAreaPadding + 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Score: ${_gameEngine.score}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Missed: ${_gameEngine.missedEnemies}',
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons - fixed at bottom of screen
            ControlButtons(
              onShoot: _shoot,
              onMoveLeft: (isPressed) {
                setState(() {
                  _gameEngine.isMovingLeft = isPressed;
                  if (isPressed) {
                    // Start with a gentler velocity rather than immediately jumping to moveSpeed
                    _gameEngine.playerVelocity = -(_gameEngine.moveSpeed / 2);
                  }
                });
              },
              onMoveRight: (isPressed) {
                setState(() {
                  _gameEngine.isMovingRight = isPressed;
                  if (isPressed) {
                    // Start with a gentler velocity rather than immediately jumping to moveSpeed
                    _gameEngine.playerVelocity = (_gameEngine.moveSpeed / 2);
                  }
                });
              },
              onSingleTapLeft: () {
                setState(() {
                  _gameEngine
                      .singleTapMove(true); // Move left with a single tap
                });
              },
              onSingleTapRight: () {
                setState(() {
                  _gameEngine
                      .singleTapMove(false); // Move right with a single tap
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
