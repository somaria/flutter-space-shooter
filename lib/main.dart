import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math' as math;
import 'database_helper.dart';
import 'widgets/control_buttons.dart';
import 'widgets/player.dart';
import 'widgets/enemy.dart';
import 'widgets/bullet.dart';
import 'widgets/starfield.dart';
import 'widgets/game_completion_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> highScores = [];

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final scores = await DatabaseHelper.instance.getHighScores(limit: 5);
    setState(() {
      highScores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.blue, width: 4.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Flutter Games',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  ).then((_) => _loadHighScores());
                },
                child: const Text(
                  'Play Space Shooter',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 40),
              if (highScores.isNotEmpty) ...[
                const Text(
                  'High Scores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...highScores.map((score) {
                  final date = DateTime.parse(score['date']);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${score['score']} pts - ${score['enemies_defeated']} enemies - ${date.month}/${date.day}/${date.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  double playerX = 0.0;
  // Add these properties for smooth movement
  double playerVelocity = 0.0;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  final double moveSpeed = 5.0;
  final double maxVelocity = 8.0;
  final double deceleration = 0.8;

  List<Offset> bullets = [];
  List<Offset> enemies = [];
  List<Offset> enemyVectors = [];
  final double enemySpeed = 1.0;
  int score = 0;
  late AnimationController _controller;
  double? screenWidth;
  int totalEnemiesSpawned = 0;
  final int maxEnemies = 10;
  bool gameCompleted = false;

  final double safeAreaPadding = 60.0;
  final double enemySize = 30.0;

  final List<Map<String, double>> stars = [];
  final int numberOfStars = 50;
  final math.Random random = math.Random();

  final double starSpeed = 0.5;
  final double starSize = 2.0;

  @override
  void initState() {
    super.initState();
    // Preload audio files
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.loadAll(['shoot.mp3', 'explosion.mp3']);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..addListener(_gameLoop);
    _controller.repeat();

    // Move enemy spawning to didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnEnemy();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;

    // Initialize stars only once
    if (stars.isEmpty) {
      for (int i = 0; i < numberOfStars; i++) {
        stars.add({
          'x': random.nextDouble() * (screenWidth ?? 400),
          'y': random.nextDouble() * MediaQuery.of(context).size.height,
          'brightness': random.nextDouble(),
        });
      }
    }
  }

  void _gameLoop() {
    setState(() {
      // Update stars
      for (var star in stars) {
        star['y'] =
            (star['y']! + starSpeed) % MediaQuery.of(context).size.height;
      }

      // Update player movement
      if (isMovingLeft) {
        playerVelocity = -maxVelocity;
      } else if (isMovingRight) {
        playerVelocity = maxVelocity;
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
        playerX = (playerX + playerVelocity)
            .clamp(4.0, MediaQuery.of(context).size.width - 54.0);
      }

      // Update bullets
      for (int i = bullets.length - 1; i >= 0; i--) {
        bullets[i] = Offset(bullets[i].dx, bullets[i].dy - 10.0);
        if (bullets[i].dy < 0) bullets.removeAt(i);
      }

      // Update enemies
      for (int i = enemies.length - 1; i >= 0; i--) {
        enemies[i] = Offset(
          enemies[i].dx + enemyVectors[i].dx * enemySpeed,
          enemies[i].dy + enemyVectors[i].dy * enemySpeed,
        );

        // Bounce off safe area boundaries
        if (enemies[i].dx <= safeAreaPadding ||
            enemies[i].dx >=
                (screenWidth ?? 300) - safeAreaPadding - enemySize) {
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
            _checkGameCompletion();
            break;
          }
        }
      }

      // Update player position based on velocity
      playerX += playerVelocity;

      // Clamp player position to screen bounds
      playerX = playerX.clamp(0, (screenWidth ?? 300) - 50);

      // Decelerate player if not moving
      if (!isMovingLeft && !isMovingRight) {
        playerVelocity *= deceleration;
        if (playerVelocity.abs() < 0.1) playerVelocity = 0;
      }
    });
  }

  void _spawnEnemy() {
    if (!mounted || totalEnemiesSpawned >= maxEnemies) return;
    if (enemies.length >= 3) {
      // Delay next spawn check if too many enemies
      Future.delayed(const Duration(seconds: 1), _spawnEnemy);
      return;
    }

    setState(() {
      final random = math.Random();
      double centerX = (screenWidth ?? 300) * 0.2 +
          random.nextDouble() * (screenWidth ?? 300) * 0.6;
      double centerY = MediaQuery.of(context).size.height * 0.2;

      enemies.add(Offset(centerX, centerY));
      totalEnemiesSpawned++;

      double angle = random.nextDouble() * 2 * math.pi;
      enemyVectors.add(Offset(math.cos(angle), math.sin(angle)));
    });

    if (totalEnemiesSpawned < maxEnemies) {
      Future.delayed(const Duration(seconds: 4), _spawnEnemy);
    }
  }

  // Checks if the game is completed and shows the dialog if so
  void _checkGameCompletion() {
    if (totalEnemiesSpawned >= maxEnemies && enemies.isEmpty) {
      setState(() {
        gameCompleted = true;
        _controller.stop();
      });
      _showGameCompletionDialog();
    }
  }

  Future<void> _showGameCompletionDialog() async {
    int enemiesKilled = score ~/ 10;

    // Save the score to the database
    await DatabaseHelper.instance.insertScore(score, enemiesKilled);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompletionDialog(
        score: score,
        enemiesDefeated: enemiesKilled,
        onBackToMenu: () {
          Navigator.of(context).pop(); // Return to home screen
        },
        onPlayAgain: _resetGame,
      ),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      enemies.clear();
      bullets.clear();
      enemyVectors.clear();
      totalEnemiesSpawned = 0;
      gameCompleted = false;

      // Reset stars
      stars.clear();
      for (int i = 0; i < numberOfStars; i++) {
        stars.add({
          'x': random.nextDouble() * (screenWidth ?? 400),
          'y': random.nextDouble() * MediaQuery.of(context).size.height,
          'brightness': random.nextDouble(),
        });
      }
    });

    // Restart the animation controller
    _controller.repeat();
    _spawnEnemy();
  }

  void _shoot() {
    setState(() {
      bullets
          .add(Offset(playerX + 25.0, MediaQuery.of(context).size.height - 80));
      FlameAudio.play('shoot.mp3', volume: 0.5);
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
      body: Column(
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
                  StarfieldWidget(stars: stars, starSize: starSize),

                  // Safe area visualization
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(safeAreaPadding),
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
                  PlayerWidget(playerX: playerX, playerY: 50),

                  // Bullets
                  ...bullets.map(
                    (bullet) => BulletWidget(position: bullet),
                  ),

                  // Enemies
                  ...enemies.map(
                    (enemy) => EnemyWidget(position: enemy, size: enemySize),
                  ),

                  // Score
                  Positioned(
                    top: 40,
                    right: 24,
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
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
                isMovingLeft = isPressed;
                if (isPressed) {
                  playerVelocity = -moveSpeed;
                }
              });
            },
            onMoveRight: (isPressed) {
              setState(() {
                isMovingRight = isPressed;
                if (isPressed) {
                  playerVelocity = moveSpeed;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
