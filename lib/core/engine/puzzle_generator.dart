import 'dart:math';
import '../../domain/models/puzzle_model.dart';
import 'puzzle_solver.dart';

/// Generates solvable CountiQ puzzles at various difficulty levels.
class PuzzleGenerator {
  static final _random = Random();

  // Number pools (inspired by Countdown TV show)
  static const List<int> _bigNumbers = [25, 50, 75, 100];
  static const List<int> _smallNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  /// Generate a puzzle at the given difficulty.
  /// Retries until a solvable puzzle is found.
  static CountiqPuzzle generate({String difficulty = 'easy'}) {
    final config = _getConfig(difficulty);

    for (int attempt = 0; attempt < 200; attempt++) {
      final numbers = _generateNumbers(
        bigCount: config.bigCount,
        smallCount: config.smallCount,
      );

      final target = _generateTarget(config.minTarget, config.maxTarget);

      // Check solvability
      final solution = PuzzleSolver.findOneSolution(numbers, target);
      if (solution != null) {
        return CountiqPuzzle(
          target: target,
          numbers: numbers,
          difficulty: difficulty,
          knownSolution: solution,
        );
      }
    }

    // Fallback: generate a puzzle we KNOW is solvable
    return _generateGuaranteedPuzzle(difficulty);
  }

  /// Generate a specific number of puzzles
  static List<CountiqPuzzle> generateBatch(int count, {String difficulty = 'easy'}) {
    return List.generate(count, (_) => generate(difficulty: difficulty));
  }

  static _DifficultyConfig _getConfig(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const _DifficultyConfig(
          minTarget: 10,
          maxTarget: 100,
          bigCount: 1,
          smallCount: 4,
        );
      case 'medium':
        return const _DifficultyConfig(
          minTarget: 100,
          maxTarget: 500,
          bigCount: 2,
          smallCount: 4,
        );
      case 'hard':
        return const _DifficultyConfig(
          minTarget: 200,
          maxTarget: 999,
          bigCount: 2,
          smallCount: 4,
        );
      default:
        return const _DifficultyConfig(
          minTarget: 10,
          maxTarget: 100,
          bigCount: 1,
          smallCount: 4,
        );
    }
  }

  static List<int> _generateNumbers({
    required int bigCount,
    required int smallCount,
  }) {
    final numbers = <int>[];

    // Pick big numbers (without replacement)
    final bigPool = List<int>.from(_bigNumbers)..shuffle(_random);
    for (int i = 0; i < bigCount && i < bigPool.length; i++) {
      numbers.add(bigPool[i]);
    }

    // Pick small numbers (with possible duplicates, like the real game)
    // In Countdown, each small number 1-10 appears twice in the pool
    final smallPool = <int>[..._smallNumbers, ..._smallNumbers]..shuffle(_random);
    for (int i = 0; i < smallCount && i < smallPool.length; i++) {
      numbers.add(smallPool[i]);
    }

    numbers.shuffle(_random);
    return numbers;
  }

  static int _generateTarget(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate a puzzle that is guaranteed to be solvable
  /// by working backwards from a known solution
  static CountiqPuzzle _generateGuaranteedPuzzle(String difficulty) {
    final config = _getConfig(difficulty);

    // Pick random numbers
    final numbers = _generateNumbers(
      bigCount: config.bigCount,
      smallCount: config.smallCount,
    );

    // Pick two random numbers and compute a target from them
    final shuffled = List<int>.from(numbers)..shuffle(_random);
    final a = shuffled[0];
    final b = shuffled[1];

    // Pick a random valid operation
    final ops = <MapEntry<String, int>>[];
    ops.add(MapEntry('+', a + b));
    if (a > b) ops.add(MapEntry('-', a - b));
    if (a > 1 && b > 1) ops.add(MapEntry('×', a * b));
    if (b > 1 && a % b == 0) ops.add(MapEntry('÷', a ~/ b));

    final chosen = ops[_random.nextInt(ops.length)];
    final target = chosen.value;

    final solution = Solution(
      steps: [
        CalcStep(
          num1: a,
          operator: chosen.key,
          num2: b,
          result: target,
        ),
      ],
    );

    // Clamp target to config range
    final clampedTarget = target.clamp(config.minTarget, config.maxTarget);

    // If clamped target changed, try the solver
    if (clampedTarget != target) {
      final sol = PuzzleSolver.findOneSolution(numbers, clampedTarget);
      if (sol != null) {
        return CountiqPuzzle(
          target: clampedTarget,
          numbers: numbers,
          difficulty: difficulty,
          knownSolution: sol,
        );
      }
    }

    return CountiqPuzzle(
      target: target,
      numbers: numbers,
      difficulty: difficulty,
      knownSolution: solution,
    );
  }
}

class _DifficultyConfig {
  final int minTarget;
  final int maxTarget;
  final int bigCount;
  final int smallCount;

  const _DifficultyConfig({
    required this.minTarget,
    required this.maxTarget,
    required this.bigCount,
    required this.smallCount,
  });
}
