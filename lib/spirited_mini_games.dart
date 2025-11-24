// spirited_mini_games.dart
// Mind Dark Theme with Purple Neon Glowing Mini Games
// Adds 8 working mini-games (Matrix Tetris, Brick Breaker, Mind Puzzle,
// Memory Vortex, Reflex Matrix, Gravity Boxes, Pattern Lock, Neon Sweeper)
// Plays music.mp3 
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SpiritedMiniGamesView extends StatefulWidget {
  const SpiritedMiniGamesView({super.key});

  static final _games = <_GameInfo>[
    _GameInfo('Quantum Snake', QuantumSnakeGame.new),
    _GameInfo('Neon Invaders', SpaceInvadersGame.new),
    _GameInfo('Matrix Tetris', MatrixTetrisGame.new),
    _GameInfo('Psychedelic Bricks', PsychedelicBrickBreaker.new),
    _GameInfo('Mind Puzzle', MindPuzzleGame.new),
    _GameInfo('Memory Vortex', MemoryVortexGame.new),
    _GameInfo('Reflex Matrix', ReflexMatrixGame.new),
    _GameInfo('Gravity Boxes', GravityBoxesGame.new),
    _GameInfo('Pattern Lock', PatternLockGame.new),
    _GameInfo('Neon Sweeper', NeonSweeperGame.new),
  ];

  @override
  State<SpiritedMiniGamesView> createState() => _SpiritedMiniGamesViewState();
}

class _SpiritedMiniGamesViewState extends State<SpiritedMiniGamesView> {
  final AudioPlayer _player = AudioPlayer();
  bool _musicStarted = false;

  @override
  void initState() {
    super.initState();
    _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      // music.mp3 should be declared in pubspec.yaml under assets
      await _player.play(AssetSource('music.mp3'));
      _musicStarted = true;
    } catch (_) {
      // ignore audio errors silently (device may not allow audio)
    }
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _mindDarkGradient(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _neonHeader('MIND TWISTER GAMES'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: SpiritedMiniGamesView._games.length,
              itemBuilder: (context, index) {
                final game = SpiritedMiniGamesView._games[index];
                return _NeonGameCard(
                  title: game.title,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => game.builder()),
                  ),
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _neonHeader(String text) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Color(0xFFBB86FC),
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: _neonBoxDecoration(),
          child: const Text(
            'Play games while waiting until system is ready',
            style: TextStyle(
              color: Color(0xFFBB86FC),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  static BoxDecoration _neonBoxDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFBB86FC).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF3700B3).withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 5,
        ),
      ],
    );
  }

  static BoxDecoration _mindDarkGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }
}

class _GameInfo {
  final String title;
  final Widget Function() builder;
  _GameInfo(this.title, this.builder);
}

class _NeonGameCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final int index;

  const _NeonGameCard({
    required this.title,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFBB86FC),
      const Color(0xFF9C27B0),
      const Color(0xFFE040FB),
      const Color(0xFF7C4DFF),
      const Color(0xFF536DFE),
      const Color(0xFF448AFF),
      const Color(0xFF40C4FF),
      const Color(0xFF18FFFF),
      const Color(0xFF64FFDA),
      const Color(0xFF69F0AE),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: SpiritedMiniGamesViewStateHelper.neonBoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset,
              color: colors[index % colors.length],
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: colors[index % colors.length].withOpacity(0.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors[index % colors.length].withOpacity(0.3),
                ),
              ),
              child: Text(
                'PLAY',
                style: TextStyle(
                  color: colors[index % colors.length],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small helper to expose the same decoration (keeps code tidy)
class SpiritedMiniGamesViewStateHelper {
  static BoxDecoration neonBoxDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFBB86FC).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }
}

// Utility function for game scaffolds
Widget _gameScaffold({
  required String title,
  required Widget body,
  required VoidCallback onBack,
}) {
  return Scaffold(
    backgroundColor: const Color(0xFF0F0F23),
    appBar: AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Color(0xFFBB86FC),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFBB86FC)),
        onPressed: onBack,
      ),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
        ),
      ),
      child: body,
    ),
  );
}

/* =============================
   1. QUANTUM SNAKE
   ============================= */
class QuantumSnakeGame extends StatefulWidget {
  const QuantumSnakeGame({super.key});
  @override
  State<QuantumSnakeGame> createState() => _QuantumSnakeGameState();
}

class _QuantumSnakeGameState extends State<QuantumSnakeGame> {
  static const int gridSize = 20;
  static const int cellSize = 15;
  List<Offset> snake = [];
  Offset food = Offset.zero;
  Offset direction = const Offset(1, 0);
  int score = 0;
  bool gameOver = false;
  bool isPaused = false;
  Timer? gameTimer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    snake = [const Offset(10, 10)];
    _generateFood();
    direction = const Offset(1, 0);
    score = 0;
    gameOver = false;
    isPaused = false;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!isPaused && !gameOver) {
        _moveSnake();
      }
    });
  }

  void _generateFood() {
    Offset newFood;
    do {
      newFood = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(newFood));
    food = newFood;
  }

  void _moveSnake() {
    final newHead = Offset(
      (snake.first.dx + direction.dx) % gridSize,
      (snake.first.dy + direction.dy) % gridSize,
    );

    if (snake.contains(newHead)) {
      setState(() => gameOver = true);
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score += 10;
        _generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx > 2 && direction != const Offset(-1, 0)) {
      direction = const Offset(1, 0);
    } else if (details.delta.dx < -2 && direction != const Offset(1, 0)) {
      direction = const Offset(-1, 0);
    } else if (details.delta.dy > 2 && direction != const Offset(0, -1)) {
      direction = const Offset(0, 1);
    } else if (details.delta.dy < -2 && direction != const Offset(0, 1)) {
      direction = const Offset(0, -1);
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Quantum Snake',
      onBack: () => Navigator.of(context).pop(),
      body: GestureDetector(
        onTap: () {
          if (gameOver) {
            _startGame();
          } else {
            setState(() => isPaused = !isPaused);
          }
        },
        onVerticalDragUpdate: _handleSwipe,
        onHorizontalDragUpdate: _handleSwipe,
        child: Container(
          color: const Color(0xFF0F0F23),
          child: Stack(
            children: [
              // Game grid
              Center(
                child: Container(
                  width: gridSize * cellSize.toDouble(),
                  height: gridSize * cellSize.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.3)),
                  ),
                  child: CustomPaint(
                    painter: _QuantumGridPainter(),
                  ),
                ),
              ),

              // Snake and food
              Center(
                child: SizedBox(
                  width: gridSize * cellSize.toDouble(),
                  height: gridSize * cellSize.toDouble(),
                  child: Stack(
                    children: [
                      // Food with glow effect
                      Positioned(
                        left: food.dx * cellSize,
                        top: food.dy * cellSize,
                        child: Container(
                          width: cellSize.toDouble(),
                          height: cellSize.toDouble(),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE040FB),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE040FB).withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Snake
                      for (int i = 0; i < snake.length; i++)
                        Positioned(
                          left: snake[i].dx * cellSize,
                          top: snake[i].dy * cellSize,
                          child: Container(
                            width: cellSize.toDouble(),
                            height: cellSize.toDouble(),
                            decoration: BoxDecoration(
                              color: i == 0 
                                  ? const Color(0xFFBB86FC)
                                  : const Color(0xFF9C27B0),
                              borderRadius: i == 0 ? BorderRadius.circular(6) : BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: (i == 0 ? const Color(0xFFBB86FC) : const Color(0xFF9C27B0)).withOpacity(0.6),
                                  blurRadius: i == 0 ? 8 : 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Game status
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'SCORE: $score',
                      style: const TextStyle(
                        color: Color(0xFFBB86FC),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Color(0xFFBB86FC),
                          ),
                        ],
                      ),
                    ),
                    if (gameOver)
                      const Text(
                        'GAME OVER! TAP TO RESTART',
                        style: TextStyle(
                          color: Color(0xFFE040FB),
                          fontSize: 16,
                        ),
                      )
                    else if (isPaused)
                      const Text(
                        'PAUSED - TAP TO RESUME',
                        style: TextStyle(
                          color: Color(0xFFBB86FC),
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantumGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBB86FC).withOpacity(0.1)
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= _QuantumSnakeGameState.gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * _QuantumSnakeGameState.cellSize.toDouble(), 0),
        Offset(i * _QuantumSnakeGameState.cellSize.toDouble(), size.height),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * _QuantumSnakeGameState.cellSize.toDouble()),
        Offset(size.width, i * _QuantumSnakeGameState.cellSize.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* =============================
   2. SPACE INVADERS (UPGRADED)
   ============================= */

class SpaceInvadersGame extends StatefulWidget {
  const SpaceInvadersGame({super.key});
  @override
  State<SpaceInvadersGame> createState() => _SpaceInvadersGameState();
}

class _SpaceInvadersGameState extends State<SpaceInvadersGame> {
  double shipX = 0.5;

  final List<Offset> invaders = [];
  final List<Offset> bullets = [];
  final List<Offset> enemyBullets = [];

  Timer? gameTimer;
  final Random random = Random();

  int score = 0;
  int lives = 3;
  bool moveRight = true;
  double enemySpeed = 0.008;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _initInvaders();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _updateGame());
  }

  void _initInvaders() {
    invaders.clear();
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 8; col++) {
        invaders.add(Offset(col * 0.10 + 0.1, row * 0.08 + 0.1));
      }
    }

    enemySpeed = 0.008;
  }

  // ENEMY SHOOTING
  void _enemyShoot() {
    if (invaders.isEmpty) return;

    // random invader fires
    if (random.nextDouble() < 0.02) {
      final shooter = invaders[random.nextInt(invaders.length)];
      enemyBullets.add(Offset(shooter.dx, shooter.dy + 0.04));
    }
  }

  void _updateGame() {
    if (gameOver) return;

    setState(() {
      // ---- Move Invaders ----
      for (int i = 0; i < invaders.length; i++) {
        invaders[i] = invaders[i].translate(moveRight ? enemySpeed : -enemySpeed, 0);
      }

      // Check walls
      bool hitWall = false;
      for (final invader in invaders) {
        if (invader.dx > 0.92 || invader.dx < 0.05) {
          hitWall = true;
          break;
        }
      }

      if (hitWall) {
        moveRight = !moveRight;
        for (int i = 0; i < invaders.length; i++) {
          invaders[i] = invaders[i].translate(0, 0.04);
        }
      }

      // Difficulty scales
      enemySpeed = 0.004 + (0.004 * (40 - invaders.length));

      // ---- Enemy Shooting ----
      _enemyShoot();

      // ---- Move Player Bullets ----
      for (int i = bullets.length - 1; i >= 0; i--) {
        bullets[i] = bullets[i].translate(0, -0.03);
        if (bullets[i].dy < 0) {
          bullets.removeAt(i);
          continue;
        }

        // Bullet collision with invaders
        for (int j = invaders.length - 1; j >= 0; j--) {
          if ((bullets[i] - invaders[j]).distance < 0.05) {
            invaders.removeAt(j);
            bullets.removeAt(i);
            score += 100;
            break;
          }
        }
      }

      // ---- Enemy Bullets ----
      for (int i = enemyBullets.length - 1; i >= 0; i--) {
        enemyBullets[i] = enemyBullets[i].translate(0, 0.02);
        if (enemyBullets[i].dy > 1.1) {
          enemyBullets.removeAt(i);
          continue;
        }

        // Hit player
        if ((enemyBullets[i] - Offset(shipX, 0.90)).distance < 0.06) {
          enemyBullets.removeAt(i);
          lives--;
          if (lives <= 0) {
            _showGameOver();
            return;
          }
        }
      }

      // ---- Invaders reached bottom ----
      for (final invader in invaders) {
        if (invader.dy > 0.8) {
          lives--;
          _initInvaders();
          if (lives <= 0) {
            _showGameOver();
            return;
          }
          break;
        }
      }

      // ---- Level Complete ----
      if (invaders.isEmpty) {
        _initInvaders();
      }
    });
  }

  void _showGameOver() {
    gameOver = true;
    gameTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A3A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "GAME OVER",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("BACK"),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _fireBullet() {
    bullets.add(Offset(shipX, 0.85));
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Neon Invaders',
      onBack: () => Navigator.of(context).pop(),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            shipX = (shipX + details.delta.dx / MediaQuery.of(context).size.width)
                .clamp(0.05, 0.95);
          });
        },
        onTap: _fireBullet,
        child: Container(
          color: const Color(0xFF0F0F23),
          child: Stack(
            children: [
              // Invaders
              for (final invader in invaders)
                Positioned(
                  left: invader.dx * MediaQuery.of(context).size.width,
                  top: invader.dy * MediaQuery.of(context).size.height,
                  child: _enemySprite(),
                ),

              // Player Bullets
              for (final bullet in bullets)
                Positioned(
                  left: bullet.dx * MediaQuery.of(context).size.width - 2,
                  top: bullet.dy * MediaQuery.of(context).size.height,
                  child: _playerBullet(),
                ),

              // Enemy Bullets
              for (final b in enemyBullets)
                Positioned(
                  left: b.dx * MediaQuery.of(context).size.width - 3,
                  top: b.dy * MediaQuery.of(context).size.height,
                  child: _enemyBullet(),
                ),

              // Player Ship
              Positioned(
                left: shipX * MediaQuery.of(context).size.width - 25,
                top: MediaQuery.of(context).size.height * 0.90,
                child: _playerShip(),
              ),

              // HUD
              Positioned(
                top: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCORE: $score',
                      style: const TextStyle(
                        color: Color(0xFFBB86FC),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'LIVES: $lives',
                      style: const TextStyle(
                        color: Color(0xFFE040FB),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ SPRITES ------------------

  Widget _enemySprite() => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFE040FB),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE040FB).withOpacity(0.6),
              blurRadius: 8,
            ),
          ],
        ),
      );

  Widget _playerBullet() => Container(
        width: 4,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFFBB86FC),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _enemyBullet() => Container(
        width: 6,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(3),
        ),
      );

  Widget _playerShip() => Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFBB86FC),
          borderRadius: BorderRadius.circular(10),
        ),
      );
}


/* =============================
   3. MATRIX TETRIS (simplified playable version)
   ============================= */
class MatrixTetrisGame extends StatefulWidget {
  const MatrixTetrisGame({super.key});
  @override
  State<MatrixTetrisGame> createState() => _MatrixTetrisGameState();
}

class _MatrixTetrisGameState extends State<MatrixTetrisGame> {
  static const int rows = 18;
  static const int cols = 10;
  static const int cellSize = 18;
  late List<List<Color?>> grid;
  late Tetromino current;
  Timer? timer;
  final Random rnd = Random();
  int score = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    reset();
    timer = Timer.periodic(const Duration(milliseconds: 400), (_) => tick());
  }

  void reset() {
    grid = List.generate(rows, (_) => List<Color?>.filled(cols, null));
    current = Tetromino.random(rnd, cols ~/ 2);
    score = 0;
    gameOver = false;
  }

  void tick() {
    if (gameOver) return;
    setState(() {
      if (!move(1, 0)) {
        // lock
        for (final p in current.blocks) {
          final r = current.row + p.dy.toInt();
          final c = current.col + p.dx.toInt();
          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            grid[r][c] = current.color;
          } else {
            gameOver = true;
          }
        }
        clearLines();
        current = Tetromino.random(rnd, cols ~/ 2);
        if (!fits(current, 0, 0)) gameOver = true;
      }
    });
  }

  void clearLines() {
    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r].every((c) => c != null)) {
        grid.removeAt(r);
        grid.insert(0, List<Color?>.filled(cols, null));
        score += 100;
        r++; // check same row again
      }
    }
  }

  bool fits(Tetromino t, int dr, int dc) {
    for (final p in t.blocks) {
      final r = t.row + p.dy.toInt() + dr;
      final c = t.col + p.dx.toInt() + dc;
      if (r < 0) continue;
      if (r >= rows || c < 0 || c >= cols) return false;
      if (grid[r][c] != null) return false;
    }
    return true;
  }

  bool move(int dr, int dc) {
    if (fits(current, dr, dc)) {
      current = current.copyWith(row: current.row + dr, col: current.col + dc);
      return true;
    }
    return false;
  }

  void rotate() {
    final rotated = current.rotated();
    if (fits(rotated, 0, 0)) current = rotated;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Matrix Tetris',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('SCORE: $score', style: const TextStyle(color: Color(0xFFBB86FC))),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: rotate,
                onHorizontalDragUpdate: (d) {
                  if (d.delta.dx > 6) move(0, 1);
                  if (d.delta.dx < -6) move(0, -1);
                  setState(() {});
                },
                child: Container(
                  width: cols * cellSize.toDouble(),
                  height: rows * cellSize.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.2)),
                  ),
                  child: CustomPaint(
                    painter: _TetrisPainter(grid: grid, current: current),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tetromino {
  final List<Offset> blocks;
  final Color color;
  final int row;
  final int col;
  Tetromino(this.blocks, this.color, {this.row = 0, this.col = 4});

  Tetromino copyWith({List<Offset>? blocks, Color? color, int? row, int? col}) {
    return Tetromino(blocks ?? this.blocks, color ?? this.color, row: row ?? this.row, col: col ?? this.col);
  }

  Tetromino rotated() {
    final rotated = blocks.map((o) => Offset(-o.dy, o.dx)).toList();
    return Tetromino(rotated, color, row: row, col: col);
  }

  static Tetromino random(Random rnd, int startCol) {
    final shapes = [
      [Offset(0,0), Offset(1,0), Offset(0,1), Offset(1,1)], // O
      [Offset(-1,0), Offset(0,0), Offset(1,0), Offset(2,0)], // I
      [Offset(0,0), Offset(1,0), Offset(0,1), Offset(0,2)], // L (simple)
      [Offset(0,0), Offset(-1,0), Offset(0,1), Offset(0,2)], // J
      [Offset(0,0), Offset(1,0), Offset(0,1), Offset(-1,1)], // S-like
    ];
    final palette = [Colors.purple, Colors.green, Colors.orange, Colors.teal, Colors.amber];
    final idx = rnd.nextInt(shapes.length);
    return Tetromino(shapes[idx], palette[idx], row: 0, col: startCol);
  }
}

class _TetrisPainter extends CustomPainter {
  final List<List<Color?>> grid;
  final Tetromino current;
  _TetrisPainter({required this.grid, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / _MatrixTetrisGameState.cols;
    final cellH = size.height / _MatrixTetrisGameState.rows;
    final paint = Paint();

    for (int r = 0; r < _MatrixTetrisGameState.rows; r++) {
      for (int c = 0; c < _MatrixTetrisGameState.cols; c++) {
        final color = grid[r][c];
        paint.color = color ?? Colors.black12;
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW - 1, cellH - 1);
        canvas.drawRect(rect, paint);
      }
    }

    paint.color = current.color;
    for (final p in current.blocks) {
      final r = current.row + p.dy.toInt();
      final c = current.col + p.dx.toInt();
      if (r >= 0 && r < _MatrixTetrisGameState.rows && c >= 0 && c < _MatrixTetrisGameState.cols) {
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW - 1, cellH - 1);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/* =============================
   4. PSYCHEDELIC BRICK BREAKER
   ============================= */
class PsychedelicBrickBreaker extends StatefulWidget {
  const PsychedelicBrickBreaker({super.key});
  @override
  State<PsychedelicBrickBreaker> createState() => _PsychedelicBrickBreakerState();
}

class _PsychedelicBrickBreakerState extends State<PsychedelicBrickBreaker> {
  double paddleX = 0.5;
  double ballX = 0.5;
  double ballY = 0.8;
  double vx = 0.01;
  double vy = -0.015;
  final int rows = 5;
  final int cols = 8;
  late List<List<bool>> bricks;
  Timer? t;
  int score = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    reset();
    t = Timer.periodic(const Duration(milliseconds: 16), (_) => step());
  }

  void reset() {
    bricks = List.generate(rows, (_) => List.generate(cols, (_) => true));
    paddleX = 0.5;
    ballX = 0.5;
    ballY = 0.8;
    vx = 0.01;
    vy = -0.015;
    score = 0;
    gameOver = false;
  }

  void step() {
    if (gameOver) return;
    setState(() {
      ballX += vx;
      ballY += vy;
      if (ballX < 0.05 || ballX > 0.95) vx = -vx;
      if (ballY < 0.02) vy = -vy;
      // paddle collision
      final paddleLeft = paddleX - 0.12;
      final paddleRight = paddleX + 0.12;
      if (ballY > 0.86 && ballX > paddleLeft && ballX < paddleRight) {
        vy = -vy.abs();
        vx += (ballX - paddleX) * 0.02;
      }
      // bricks
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (!bricks[r][c]) continue;
          final bx = (c + 0.5) / cols;
          final by = (r + 0.5) * 0.06 + 0.06;
          if ((ballX - bx).abs() < 1 / cols && (ballY - by).abs() < 0.03) {
            bricks[r][c] = false;
            vy = -vy;
            score += 50;
          }
        }
      }
      if (ballY > 1.0) {
        gameOver = true;
      }
      if (bricks.expand((e) => e).every((b) => !b)) {
        // win -> reset with more speed
        vx *= 1.1;
        vy *= 1.1;
        reset();
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Psychedelic Bricks',
      onBack: () => Navigator.of(context).pop(),
      body: GestureDetector(
        onHorizontalDragUpdate: (d) {
          setState(() {
            paddleX = (paddleX + d.delta.dx / MediaQuery.of(context).size.width).clamp(0.1, 0.9);
          });
        },
        onTap: () {
          if (gameOver) reset();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BrickPainter(paddleX, ballX, ballY, bricks),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Text('SCORE: $score', style: const TextStyle(color: Color(0xFFBB86FC))),
            ),
            if (gameOver)
              Center(
                child: ElevatedButton(
                  onPressed: reset,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB86FC)),
                  child: const Text('RESTART'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrickPainter extends CustomPainter {
  final double paddleX, ballX, ballY;
  final List<List<bool>> bricks;
  _BrickPainter(this.paddleX, this.ballX, this.ballY, this.bricks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // bricks
    final rows = bricks.length;
    final cols = bricks[0].length;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!bricks[r][c]) continue;
        paint.color = Color.lerp(const Color(0xFFE040FB), const Color(0xFF40C4FF), r / rows)!;
        final w = size.width / cols;
        final h = size.height * 0.06;
        final rect = Rect.fromLTWH(c * w + 4, r * h + 20, w - 8, h - 8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
      }
    }
    // paddle
    paint.color = const Color(0xFFBB86FC);
    final paddleW = size.width * 0.24;
    final px = (paddleX * (size.width - paddleW));
    final paddleRect = Rect.fromLTWH(px, size.height * 0.9, paddleW, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(paddleRect, const Radius.circular(8)), paint);
    // ball
    paint.color = const Color(0xFFBB86FC);
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/* =============================
   5. MIND PUZZLE (sliding 3x3)
   ============================= */
class MindPuzzleGame extends StatefulWidget {
  const MindPuzzleGame({super.key});
  @override
  State<MindPuzzleGame> createState() => _MindPuzzleGameState();
}

class _MindPuzzleGameState extends State<MindPuzzleGame> {
  late List<int> tiles;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    tiles = List.generate(9, (i) => i);
    tiles.shuffle();
    if (!_solvable(tiles)) {
      // swap two to make solvable
      final a = tiles[0];
      tiles[0] = tiles[1];
      tiles[1] = a;
    }
    setState(() {});
  }

  bool _solvable(List<int> arr) {
    final inv = <int>[];
    for (final v in arr) if (v != 0) inv.add(v);
    int invCount = 0;
    for (int i = 0; i < inv.length; i++) {
      for (int j = i + 1; j < inv.length; j++) {
        if (inv[i] > inv[j]) invCount++;
      }
    }
    return invCount % 2 == 0;
  }

  void tapTile(int idx) {
    final zero = tiles.indexOf(0);
    final r1 = idx ~/ 3, c1 = idx % 3;
    final r0 = zero ~/ 3, c0 = zero % 3;
    if ((r1 - r0).abs() + (c1 - c0).abs() == 1) {
      setState(() {
        tiles[zero] = tiles[idx];
        tiles[idx] = 0;
      });
    }
  }

  bool get solved => List.generate(9, (i) => i).every((v) => tiles[v] == v);

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Mind Puzzle',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ElevatedButton(onPressed: reset, child: const Text('Shuffle')),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (c, i) {
                    final v = tiles[i];
                    return GestureDetector(
                      onTap: () => tapTile(i),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: v == 0 ? Colors.black12 : const Color(0xFF9C27B0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: v == 0
                              ? const SizedBox.shrink()
                              : Text('${v}', style: const TextStyle(color: Colors.white, fontSize: 24)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (solved)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('SOLVED!', style: const TextStyle(color: Color(0xFFBB86FC), fontSize: 20)),
            ),
        ],
      ),
    );
  }
}

/* =============================
   6. MEMORY VORTEX (match pairs)
   ============================= */
class MemoryVortexGame extends StatefulWidget {
  const MemoryVortexGame({super.key});
  @override
  State<MemoryVortexGame> createState() => _MemoryVortexGameState();
}

class _MemoryVortexGameState extends State<MemoryVortexGame> {
  late List<int> deck;
  late List<bool> revealed;
  int first = -1;
  Timer? flipBack;
  int matches = 0;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    final base = List<int>.generate(8, (i) => i + 1);
    deck = [...base, ...base]..shuffle();
    revealed = List<bool>.filled(deck.length, false);
    first = -1;
    matches = 0;
    flipBack?.cancel();
    setState(() {});
  }

  void flip(int idx) {
    if (revealed[idx]) return;
    setState(() => revealed[idx] = true);
    if (first == -1) {
      first = idx;
      return;
    }
    if (deck[first] == deck[idx]) {
      matches++;
      first = -1;
      if (matches == 8) {
        // win
      }
    } else {
      flipBack?.cancel();
      flipBack = Timer(const Duration(milliseconds: 600), () {
        setState(() {
          revealed[first] = false;
          revealed[idx] = false;
          first = -1;
        });
      });
    }
  }

  @override
  void dispose() {
    flipBack?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Memory Vortex',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ElevatedButton(onPressed: reset, child: const Text('Shuffle')),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deck.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemBuilder: (c, i) {
                return GestureDetector(
                  onTap: () => flip(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: revealed[i] ? const Color(0xFF7C4DFF) : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: revealed[i]
                          ? Text('${deck[i]}', style: const TextStyle(color: Colors.white, fontSize: 20))
                          : const Icon(Icons.help_outline, color: Colors.white30),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* =============================
   7. REFLEX MATRIX (tap targets)
   ============================= */
class ReflexMatrixGame extends StatefulWidget {
  const ReflexMatrixGame({super.key});
  @override
  State<ReflexMatrixGame> createState() => _ReflexMatrixGameState();
}

class _ReflexMatrixGameState extends State<ReflexMatrixGame> {
  int score = 0;
  int timeLeft = 15;
  Timer? gameTimer;
  Timer? spawnTimer;
  Set<int> active = {};

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() {
    score = 0;
    timeLeft = 15;
    active.clear();
    gameTimer?.cancel();
    spawnTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          gameTimer?.cancel();
          spawnTimer?.cancel();
        }
      });
    });
    spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (active.length < 3) active.add(Random().nextInt(9));
      // fade random
      if (Random().nextDouble() < 0.4 && active.isNotEmpty) active.remove(active.first);
      setState(() {});
    });
  }

  void tapCell(int i) {
    if (active.contains(i)) {
      score += 10;
      active.remove(i);
      setState(() {});
    } else {
      score = max(0, score - 5);
      setState(() {});
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Reflex Matrix',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('TIME: $timeLeft  SCORE: $score', style: const TextStyle(color: Color(0xFFBB86FC))),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(9, (i) {
                final on = active.contains(i);
                return GestureDetector(
                  onTap: () => tapCell(i),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: on ? const Color(0xFF64FFDA) : Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: on ? const Icon(Icons.flash_on) : const SizedBox.shrink()),
                  ),
                );
              }),
            ),
          ),
          ElevatedButton(onPressed: start, child: const Text('RESTART')),
        ],
      ),
    );
  }
}

/* =============================
   8. GRAVITY BOXES (stacking)
   ============================= */
class GravityBoxesGame extends StatefulWidget {
  const GravityBoxesGame({super.key});
  @override
  State<GravityBoxesGame> createState() => _GravityBoxesGameState();
}

class _GravityBoxesGameState extends State<GravityBoxesGame> {
  final List<Offset> boxes = [];
  Timer? t;
  double gravity = 0.02;
  bool running = true;
  int score = 0;

  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 50), (_) => step());
  }

  void step() {
    if (!running) return;
    setState(() {
      for (int i = 0; i < boxes.length; i++) {
        final b = boxes[i];
        var ny = b.dy + gravity;
        if (ny > 0.92) {
          ny = 0.92;
        }
        boxes[i] = Offset(b.dx, ny);
      }
      // if many stacked -> convert to score and remove
      if (boxes.length > 12) {
        score += 10;
        boxes.removeRange(0, 4);
      }
    });
  }

  void spawn() {
    if (boxes.length > 18) return;
    final x = 0.1 + Random().nextDouble() * 0.8;
    boxes.add(Offset(x, 0.02));
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Gravity Boxes',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('SCORE: $score', style: const TextStyle(color: Color(0xFFBB86FC))),
          const SizedBox(height: 12),
          Expanded(
            child: GestureDetector(
              onTap: spawn,
              child: Container(
                color: Colors.black,
                child: CustomPaint(
                  painter: _GravityPainter(boxes),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () { setState(() { boxes.clear(); score = 0; }); }, child: const Text('RESET')),
        ],
      ),
    );
  }
}

class _GravityPainter extends CustomPainter {
  final List<Offset> boxes;
  _GravityPainter(this.boxes);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF40C4FF);
    for (final b in boxes) {
      final rect = Rect.fromCenter(center: Offset(b.dx * size.width, b.dy * size.height), width: 28, height: 28);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/* =============================
   9. PATTERN LOCK (connect the dots)
   ============================= */
class PatternLockGame extends StatefulWidget {
  const PatternLockGame({super.key});
  @override
  State<PatternLockGame> createState() => _PatternLockGameState();
}

class _PatternLockGameState extends State<PatternLockGame> {
  final List<int> path = [];
  final List<Offset> nodes = List.generate(9, (i) {
    final r = i ~/ 3;
    final c = i % 3;
    return Offset(c.toDouble(), r.toDouble());
  });

  void restart() {
    path.clear();
    setState(() {});
  }

  void onTapNode(int idx) {
    if (!path.contains(idx)) {
      path.add(idx);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Pattern Lock',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('PATTERN LENGTH: ${path.length}', style: const TextStyle(color: Color(0xFFBB86FC))),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: GestureDetector(
                child: Container(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: _PatternPainter(nodes, path),
                  ),
                ),
                onTapDown: (details) {
                  // detect which node tapped
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final local = box.globalToLocal(details.globalPosition);
                  final cell = 300 / 3;
                  final c = (local.dx / cell).clamp(0, 2).toInt();
                  final r = (local.dy / cell).clamp(0, 2).toInt();
                  final idx = r * 3 + c;
                  onTapNode(idx);
                },
              ),
            ),
          ),
          ElevatedButton(onPressed: restart, child: const Text('RESET')),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> nodes;
  final List<int> path;
  _PatternPainter(this.nodes, this.path);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 6..style = PaintingStyle.stroke..color = const Color(0xFFBB86FC);
    final cell = size.width / 3;
    for (int i = 0; i < nodes.length; i++) {
      final nx = nodes[i].dx * cell + cell / 2;
      final ny = nodes[i].dy * cell + cell / 2;
      final circlePaint = Paint()..color = const Color(0xFF1A1A2E);
      canvas.drawCircle(Offset(nx, ny), 28, circlePaint);
      canvas.drawCircle(Offset(nx, ny), 20, Paint()..color = const Color(0xFFBB86FC));
    }
    if (path.isNotEmpty) {
      final pathPainter = Paint()..color = const Color(0xFF64FFDA)..strokeWidth = 6;
      for (int i = 0; i < path.length - 1; i++) {
        final a = path[i];
        final b = path[i + 1];
        final ax = nodes[a].dx * cell + cell / 2;
        final ay = nodes[a].dy * cell + cell / 2;
        final bx = nodes[b].dx * cell + cell / 2;
        final by = nodes[b].dy * cell + cell / 2;
        canvas.drawLine(Offset(ax, ay), Offset(bx, by), pathPainter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/* =============================
   10. NEON SWEEPER (simple minesweeper)
   ============================= */
class NeonSweeperGame extends StatefulWidget {
  const NeonSweeperGame({super.key});
  @override
  State<NeonSweeperGame> createState() => _NeonSweeperGameState();
}

class _NeonSweeperGameState extends State<NeonSweeperGame> {
  static const int rows = 8;
  static const int cols = 8;
  static const int mines = 10;
  late List<List<int>> board; // -1 mine, 0..n counts
  late List<List<bool>> exposed;
  late List<List<bool>> flagged;
  bool lost = false;
  bool won = false;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    lost = false;
    won = false;
    board = List.generate(rows, (_) => List<int>.filled(cols, 0));
    exposed = List.generate(rows, (_) => List<bool>.filled(cols, false));
    flagged = List.generate(rows, (_) => List<bool>.filled(cols, false));
    _placeMines();
    setState(() {});
  }

  void _placeMines() {
    final rnd = Random();
    int placed = 0;
    while (placed < mines) {
      final r = rnd.nextInt(rows);
      final c = rnd.nextInt(cols);
      if (board[r][c] == -1) continue;
      board[r][c] = -1;
      placed++;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == -1) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = r + dr, nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc] == -1) count++;
          }
        }
        board[r][c] = count;
      }
    }
  }

  void reveal(int r, int c) {
    if (exposed[r][c] || flagged[r][c] || lost) return;
    exposed[r][c] = true;
    if (board[r][c] == -1) {
      lost = true;
      setState(() {});
      return;
    }
    if (board[r][c] == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && !exposed[nr][nc]) {
            reveal(nr, nc);
          }
        }
      }
    }
    _checkWin();
    setState(() {});
  }

  void toggleFlag(int r, int c) {
    if (exposed[r][c] || lost) return;
    flagged[r][c] = !flagged[r][c];
    setState(() {});
  }

  void _checkWin() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] != -1 && !exposed[r][c]) return;
      }
    }
    won = true;
  }

  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Neon Sweeper',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(onPressed: reset, child: const Text('RESET')),
            Text(lost ? 'BOOM' : (won ? 'WIN' : 'GOOD LUCK'), style: const TextStyle(color: Color(0xFFBB86FC))),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols),
                  itemCount: rows * cols,
                  itemBuilder: (c, i) {
                    final r = i ~/ cols;
                    final col = i % cols;
                    final isExposed = exposed[r][col];
                    final isFlag = flagged[r][col];
                    final val = board[r][col];
                    return GestureDetector(
                      onTap: () => reveal(r, col),
                      onLongPress: () => toggleFlag(r, col),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isExposed ? (val == -1 ? Colors.red : const Color(0xFF16213E)) : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.12)),
                        ),
                        child: Center(
                          child: isExposed
                              ? (val == -1 ? const Icon(Icons.ac_unit, color: Colors.white) : Text(val == 0 ? '' : '$val', style: const TextStyle(color: Colors.white)))
                              : (isFlag ? const Icon(Icons.flag, color: Color(0xFFE040FB)) : const SizedBox.shrink()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}