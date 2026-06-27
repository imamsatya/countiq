import 'dart:math';
import '../../domain/models/puzzle_model.dart';
import 'puzzle_solver.dart';

/// Generates deterministic campaign levels using a seeded random.
/// Each level number always produces the same puzzle.
class CampaignGenerator {
  /// Generate a campaign puzzle for a specific level number.
  /// Same level number = same puzzle every time (seeded).
  static CountiqPuzzle generateLevel(int levelNumber) {
    final seed = levelNumber * 31337 + 42;
    final random = Random(seed);
    final difficulty = _getDifficulty(levelNumber);
    final config = _getConfig(difficulty);

    // Try multiple seeds to find a solvable puzzle
    for (int attempt = 0; attempt < 50; attempt++) {
      final attemptSeed = seed + attempt * 7919;
      final rng = Random(attemptSeed);

      final numbers = _generateNumbers(rng, config);
      final target = config.minTarget + rng.nextInt(config.maxTarget - config.minTarget + 1);

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

    // Fallback: build puzzle from known solution
    return _buildFromSolution(random, difficulty, config);
  }

  static String _getDifficulty(int level) {
    if (level <= 30) return 'easy';
    if (level <= 70) return 'medium';
    return 'hard';
  }

  static _CConfig _getConfig(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const _CConfig(minTarget: 10, maxTarget: 80, bigCount: 1, smallCount: 4);
      case 'medium':
        return const _CConfig(minTarget: 50, maxTarget: 300, bigCount: 2, smallCount: 4);
      case 'hard':
        return const _CConfig(minTarget: 100, maxTarget: 999, bigCount: 2, smallCount: 4);
      default:
        return const _CConfig(minTarget: 10, maxTarget: 80, bigCount: 1, smallCount: 4);
    }
  }

  static const List<int> _bigNumbers = [25, 50, 75, 100];
  static const List<int> _smallNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  static List<int> _generateNumbers(Random rng, _CConfig config) {
    final numbers = <int>[];
    final bigPool = List<int>.from(_bigNumbers)..shuffle(rng);
    for (int i = 0; i < config.bigCount && i < bigPool.length; i++) {
      numbers.add(bigPool[i]);
    }
    final smallPool = <int>[..._smallNumbers, ..._smallNumbers]..shuffle(rng);
    for (int i = 0; i < config.smallCount && i < smallPool.length; i++) {
      numbers.add(smallPool[i]);
    }
    numbers.shuffle(rng);
    return numbers;
  }

  static CountiqPuzzle _buildFromSolution(Random rng, String difficulty, _CConfig config) {
    final numbers = _generateNumbers(rng, config);
    final a = numbers[0];
    final b = numbers[1];
    final target = a + b;

    return CountiqPuzzle(
      target: target.clamp(config.minTarget, config.maxTarget),
      numbers: numbers,
      difficulty: difficulty,
      knownSolution: Solution(steps: [
        CalcStep(num1: a, operator: '+', num2: b, result: a + b),
      ]),
    );
  }
}

class _CConfig {
  final int minTarget;
  final int maxTarget;
  final int bigCount;
  final int smallCount;

  const _CConfig({
    required this.minTarget,
    required this.maxTarget,
    required this.bigCount,
    required this.smallCount,
  });
}
