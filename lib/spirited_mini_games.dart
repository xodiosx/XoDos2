// spirited_mini_games.dart
// Mind Dark Theme with Purple Neon Glowing Mini Games

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpiritedMiniGamesView extends StatelessWidget {
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
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
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
            'Dark Mind • Purple Neon • Brain Twisters',
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
        decoration: SpiritedMiniGamesView._neonBoxDecoration(),
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
   2. SPACE INVADERS
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
  Timer? gameTimer;
  final Random random = Random();
  int score = 0;
  int lives = 3;

  @override
  void initState() {
    super.initState();
    _initInvaders();
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _updateGame());
  }

  void _initInvaders() {
    invaders.clear();
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 8; col++) {
        invaders.add(Offset(col * 0.12 + 0.1, row * 0.08 + 0.1));
      }
    }
  }

  void _updateGame() {
    setState(() {
      // Move invaders
      for (int i = 0; i < invaders.length; i++) {
        invaders[i] = invaders[i].translate(0.005, 0);
        if (invaders[i].dx > 0.9) {
          invaders[i] = Offset(0.1, invaders[i].dy + 0.05);
        }
      }

      // Move bullets
      for (int i = bullets.length - 1; i >= 0; i--) {
        bullets[i] = bullets[i].translate(0, -0.03);
        if (bullets[i].dy < 0) {
          bullets.removeAt(i);
          continue;
        }

        // Check collisions
        for (int j = invaders.length - 1; j >= 0; j--) {
          if ((bullets[i] - invaders[j]).distance < 0.04) {
            invaders.removeAt(j);
            bullets.removeAt(i);
            score += 100;
            break;
          }
        }
      }

      // Check if invaders reached bottom
      for (final invader in invaders) {
        if (invader.dy > 0.8) {
          lives--;
          _initInvaders();
          break;
        }
      }

      if (invaders.isEmpty) {
        _initInvaders();
      }

      if (lives <= 0) {
        gameTimer?.cancel();
      }
    });
  }

  void _fireBullet() {
    setState(() {
      bullets.add(Offset(shipX, 0.85));
    });
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
                .clamp(0.1, 0.9);
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
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE040FB),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE040FB).withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

              // Bullets
              for (final bullet in bullets)
                Positioned(
                  left: bullet.dx * MediaQuery.of(context).size.width - 2,
                  top: bullet.dy * MediaQuery.of(context).size.height,
                  child: Container(
                    width: 4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBB86FC),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBB86FC).withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

              // Player ship
              Positioned(
                left: shipX * MediaQuery.of(context).size.width - 25,
                top: MediaQuery.of(context).size.height * 0.9,
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB86FC),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBB86FC).withOpacity(0.6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),

              // Game status
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
                    if (lives <= 0)
                      const Text(
                        'GAME OVER',
                        style: TextStyle(
                          color: Color(0xFFE040FB),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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

/* =============================
   3. MATRIX TETRIS
   ============================= */
class MatrixTetrisGame extends StatefulWidget {
  const MatrixTetrisGame({super.key});
  @override
  State<MatrixTetrisGame> createState() => _MatrixTetrisGameState();
}

class _MatrixTetrisGameState extends State<MatrixTetrisGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Matrix Tetris',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.developer_board,
              size: 80,
              color: Color(0xFFBB86FC),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFFBB86FC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Matrix Tetris is under development',
              style: TextStyle(
                color: Color(0xFFE040FB),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'BACK TO GAMES',
                style: TextStyle(
                  color: Colors.white,
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

/* =============================
   4. PSYCHEDELIC BRICK BREAKER
   ============================= */
class PsychedelicBrickBreaker extends StatefulWidget {
  const PsychedelicBrickBreaker({super.key});
  @override
  State<PsychedelicBrickBreaker> createState() => _PsychedelicBrickBreakerState();
}

class _PsychedelicBrickBreakerState extends State<PsychedelicBrickBreaker> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Psychedelic Bricks',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Color(0xFFE040FB),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFFE040FB),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Psychedelic Bricks is under development',
              style: TextStyle(
                color: Color(0xFFBB86FC),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   5. MIND PUZZLE
   ============================= */
class MindPuzzleGame extends StatefulWidget {
  const MindPuzzleGame({super.key});
  @override
  State<MindPuzzleGame> createState() => _MindPuzzleGameState();
}

class _MindPuzzleGameState extends State<MindPuzzleGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Mind Puzzle',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: Color(0xFF9C27B0),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF9C27B0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   6. MEMORY VORTEX
   ============================= */
class MemoryVortexGame extends StatefulWidget {
  const MemoryVortexGame({super.key});
  @override
  State<MemoryVortexGame> createState() => _MemoryVortexGameState();
}

class _MemoryVortexGameState extends State<MemoryVortexGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Memory Vortex',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.memory,
              size: 80,
              color: Color(0xFF7C4DFF),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF7C4DFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   7. REFLEX MATRIX
   ============================= */
class ReflexMatrixGame extends StatefulWidget {
  const ReflexMatrixGame({super.key});
  @override
  State<ReflexMatrixGame> createState() => _ReflexMatrixGameState();
}

class _ReflexMatrixGameState extends State<ReflexMatrixGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Reflex Matrix',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flash_on,
              size: 80,
              color: Color(0xFF536DFE),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF536DFE),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   8. GRAVITY BOXES
   ============================= */
class GravityBoxesGame extends StatefulWidget {
  const GravityBoxesGame({super.key});
  @override
  State<GravityBoxesGame> createState() => _GravityBoxesGameState();
}

class _GravityBoxesGameState extends State<GravityBoxesGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Gravity Boxes',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.invert_colors,
              size: 80,
              color: Color(0xFF448AFF),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF448AFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   9. PATTERN LOCK
   ============================= */
class PatternLockGame extends StatefulWidget {
  const PatternLockGame({super.key});
  @override
  State<PatternLockGame> createState() => _PatternLockGameState();
}

class _PatternLockGameState extends State<PatternLockGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Pattern Lock',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pattern,
              size: 80,
              color: Color(0xFF40C4FF),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF40C4FF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =============================
   10. NEON SWEEPER
   ============================= */
class NeonSweeperGame extends StatefulWidget {
  const NeonSweeperGame({super.key});
  @override
  State<NeonSweeperGame> createState() => _NeonSweeperGameState();
}

class _NeonSweeperGameState extends State<NeonSweeperGame> {
  @override
  Widget build(BuildContext context) {
    return _gameScaffold(
      title: 'Neon Sweeper',
      onBack: () => Navigator.of(context).pop(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.grid_on,
              size: 80,
              color: Color(0xFF18FFFF),
            ),
            const SizedBox(height: 20),
            const Text(
              'COMING SOON',
              style: TextStyle(
                color: Color(0xFF18FFFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}