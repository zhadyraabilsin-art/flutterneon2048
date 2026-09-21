import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const Neon2048App());
}

class Neon2048App extends StatelessWidget {
  const Neon2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon 2048 Puzzle',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Game2048Screen(),
    );
  }
}

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  static const int _size = 4;
  late List<List<int>> _grid;
  int _score = 0;
  int _bestScore = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _grid = List.generate(_size, (_) => List.filled(_size, 0));
      _score = 0;
      _spawnTile();
      _spawnTile();
    });
  }

  void _spawnTile() {
    final emptyCells = <(int, int)>[];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] == 0) emptyCells.add((r, c));
      }
    }
    if (emptyCells.isEmpty) return;
    final pos = emptyCells[_random.nextInt(emptyCells.length)];
    _grid[pos.$1][pos.$2] = _random.nextInt(10) == 0 ? 4 : 2;
  }

  List<int> _slideAndMergeRow(List<int> row) {
    final nonZero = row.where((v) => v != 0).toList();
    final merged = <int>[];
    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final combined = nonZero[i] * 2;
        merged.add(combined);
        _score += combined;
        if (_score > _bestScore) _bestScore = _score;
        i += 2;
      } else {
        merged.add(nonZero[i]);
        i++;
      }
    }
    while (merged.length < _size) {
      merged.add(0);
    }
    return merged;
  }

  void _moveLeft() {
    bool changed = false;
    for (int r = 0; r < _size; r++) {
      final newRow = _slideAndMergeRow(_grid[r]);
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] != newRow[c]) changed = true;
      }
      _grid[r] = newRow;
    }
    if (changed) setState(_spawnTile);
  }

  void _moveRight() {
    bool changed = false;
    for (int r = 0; r < _size; r++) {
      final reversed = _grid[r].reversed.toList();
      final newRow = _slideAndMergeRow(reversed).reversed.toList();
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] != newRow[c]) changed = true;
      }
      _grid[r] = newRow;
    }
    if (changed) setState(_spawnTile);
  }

  void _moveUp() {
    bool changed = false;
    for (int c = 0; c < _size; c++) {
      final col = [for (int r = 0; r < _size; r++) _grid[r][c]];
      final newCol = _slideAndMergeRow(col);
      for (int r = 0; r < _size; r++) {
        if (_grid[r][c] != newCol[r]) changed = true;
        _grid[r][c] = newCol[r];
      }
    }
    if (changed) setState(_spawnTile);
  }

  void _moveDown() {
    bool changed = false;
    for (int c = 0; c < _size; c++) {
      final col = [for (int r = _size - 1; r >= 0; r--) _grid[r][c]];
      final newCol = _slideAndMergeRow(col);
      for (int r = 0; r < _size; r++) {
        final val = newCol[_size - 1 - r];
        if (_grid[r][c] != val) changed = true;
        _grid[r][c] = val;
      }
    }
    if (changed) setState(_spawnTile);
  }

  Color _tileColor(int val) {
    switch (val) {
      case 0:
        return const Color(0xFF151928);
      case 2:
        return Colors.cyanAccent.withValues(alpha: 0.25);
      case 4:
        return Colors.tealAccent.withValues(alpha: 0.35);
      case 8:
        return Colors.greenAccent.withValues(alpha: 0.45);
      case 16:
        return Colors.amberAccent.withValues(alpha: 0.55);
      case 32:
        return Colors.orangeAccent.withValues(alpha: 0.65);
      case 64:
        return Colors.pinkAccent.withValues(alpha: 0.75);
      case 128:
        return Colors.purpleAccent.withValues(alpha: 0.8);
      default:
        return Colors.deepPurpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'NEON 2048',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _scoreCard('SCORE', '$_score', Colors.cyanAccent),
                _scoreCard('BEST', '$_bestScore', Colors.amberAccent),
              ],
            ),
            const Spacer(),
            AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final vx = details.primaryVelocity ?? 0;
                  if (vx > 100) _moveRight();
                  if (vx < -100) _moveLeft();
                },
                onVerticalDragEnd: (details) {
                  final vy = details.primaryVelocity ?? 0;
                  if (vy > 100) _moveDown();
                  if (vy < -100) _moveUp();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101422),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _size * _size,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _size,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (ctx, index) {
                      final r = index ~/ _size;
                      final c = index % _size;
                      final val = _grid[r][c];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: _tileColor(val),
                          borderRadius: BorderRadius.circular(12),
                          border: val > 0
                              ? Border.all(color: Colors.white24)
                              : null,
                        ),
                        child: Center(
                          child: val == 0
                              ? null
                              : Text(
                                  '$val',
                                  style: TextStyle(
                                    fontSize: val >= 1024 ? 22 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _moveLeft,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _moveUp,
                  icon: const Icon(Icons.arrow_upward),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _moveDown,
                  icon: const Icon(Icons.arrow_downward),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _moveRight,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _newGame,
              icon: const Icon(Icons.refresh),
              label: const Text('New Game'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
