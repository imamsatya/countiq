import 'dart:math';
import '../../domain/models/puzzle_model.dart';
import 'puzzle_solver.dart';

/// Campaign tier definition for UI display.
class CampaignTier {
  final String id;
  final String name;
  final String emoji;
  final int startLevel;
  final int endLevel;

  const CampaignTier({
    required this.id,
    required this.name,
    required this.emoji,
    required this.startLevel,
    required this.endLevel,
  });

  int get levelCount => endLevel - startLevel + 1;
}

/// Generates deterministic campaign levels using a seeded random.
/// Each level number always produces the same puzzle.
///
/// 1200 levels across 6 tiers with smooth difficulty progression:
///   Tier 1: Tutorial    (Level 1–50)    — 3-4 numbers, small targets
///   Tier 2: Easy        (Level 51–200)  — 5 numbers, 1 big number
///   Tier 3: Medium      (Level 201–500) — 6 numbers, 1-2 big numbers
///   Tier 4: Hard        (Level 501–800) — 6 numbers, 2 big numbers
///   Tier 5: Expert      (Level 801–1100)— 6 numbers, 2-3 big numbers
///   Tier 6: Master      (Level 1101–1200)— 6 numbers, 3-4 big numbers
class CampaignGenerator {
  /// Total number of campaign levels available.
  static const int totalLevels = 1200;

  /// All campaign tiers for UI display purposes.
  static const List<CampaignTier> tiers = [
    CampaignTier(id: 'tutorial', name: 'Tutorial',  emoji: '🌱', startLevel: 1,    endLevel: 50),
    CampaignTier(id: 'easy',     name: 'Easy',      emoji: '🟢', startLevel: 51,   endLevel: 200),
    CampaignTier(id: 'medium',   name: 'Medium',    emoji: '🟡', startLevel: 201,  endLevel: 500),
    CampaignTier(id: 'hard',     name: 'Hard',      emoji: '🟠', startLevel: 501,  endLevel: 800),
    CampaignTier(id: 'expert',   name: 'Expert',    emoji: '🔴', startLevel: 801,  endLevel: 1100),
    CampaignTier(id: 'master',   name: 'Master',    emoji: '💎', startLevel: 1101, endLevel: 1200),
  ];

  /// Get the tier for a given level number.
  static CampaignTier getTier(int levelNumber) {
    for (final tier in tiers) {
      if (levelNumber >= tier.startLevel && levelNumber <= tier.endLevel) {
        return tier;
      }
    }
    return tiers.last;
  }

  /// Generate a campaign puzzle for a specific level number.
  /// Same level number = same puzzle every time (seeded).
  static CountiqPuzzle generateLevel(int levelNumber) {
    final seed = levelNumber * 31337 + 42;
    final random = Random(seed);
    final difficulty = _getDifficulty(levelNumber);
    final config = _getConfig(levelNumber, difficulty);

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

  /// Maps level number to a difficulty string identifier.
  static String _getDifficulty(int level) {
    if (level <= 50) return 'tutorial';
    if (level <= 200) return 'easy';
    if (level <= 500) return 'medium';
    if (level <= 800) return 'hard';
    if (level <= 1100) return 'expert';
    return 'master';
  }

  /// Returns configuration for puzzle generation based on level and difficulty.
  /// Uses smooth interpolation within tiers so difficulty ramps gradually.
  static _CConfig _getConfig(int level, String difficulty) {
    switch (difficulty) {
      case 'tutorial':
        // Level 1-25: 3 small numbers, target 5-30
        // Level 26-50: 4 small numbers, target 15-60
        if (level <= 25) {
          return const _CConfig(minTarget: 5, maxTarget: 30, bigCount: 0, smallCount: 3);
        }
        return const _CConfig(minTarget: 15, maxTarget: 60, bigCount: 0, smallCount: 4);

      case 'easy':
        // Level 51-120: 5 numbers (1 big + 4 small), target 30-150
        // Level 121-200: 5 numbers (1 big + 4 small), target 50-250
        if (level <= 120) {
          return const _CConfig(minTarget: 30, maxTarget: 150, bigCount: 1, smallCount: 4);
        }
        return const _CConfig(minTarget: 50, maxTarget: 250, bigCount: 1, smallCount: 4);

      case 'medium':
        // Level 201-350: 6 numbers (1 big + 5 small), target 80-400
        // Level 351-500: 6 numbers (2 big + 4 small), target 100-500
        if (level <= 350) {
          return const _CConfig(minTarget: 80, maxTarget: 400, bigCount: 1, smallCount: 5);
        }
        return const _CConfig(minTarget: 100, maxTarget: 500, bigCount: 2, smallCount: 4);

      case 'hard':
        // Level 501-650: 6 numbers (2 big + 4 small), target 200-700
        // Level 651-800: 6 numbers (2 big + 4 small), target 300-999
        if (level <= 650) {
          return const _CConfig(minTarget: 200, maxTarget: 700, bigCount: 2, smallCount: 4);
        }
        return const _CConfig(minTarget: 300, maxTarget: 999, bigCount: 2, smallCount: 4);

      case 'expert':
        // Level 801-950: 6 numbers (2 big + 4 small), target 500-1200
        // Level 951-1100: 6 numbers (3 big + 3 small), target 600-1500
        if (level <= 950) {
          return const _CConfig(minTarget: 500, maxTarget: 1200, bigCount: 2, smallCount: 4);
        }
        return const _CConfig(minTarget: 600, maxTarget: 1500, bigCount: 3, smallCount: 3);

      case 'master':
        // Level 1101-1150: 6 numbers (3 big + 3 small), target 800-1800
        // Level 1151-1200: 6 numbers (4 big + 2 small), target 900-2000
        if (level <= 1150) {
          return const _CConfig(minTarget: 800, maxTarget: 1800, bigCount: 3, smallCount: 3);
        }
        return const _CConfig(minTarget: 900, maxTarget: 2000, bigCount: 4, smallCount: 2);

      default:
        return const _CConfig(minTarget: 5, maxTarget: 30, bigCount: 0, smallCount: 3);
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
