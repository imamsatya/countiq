import 'dart:math';
import '../../domain/models/puzzle_model.dart';
import '../../core/engine/puzzle_solver.dart';
import '../../data/datasources/local_database.dart';

/// Manages daily challenge puzzles.
/// Each day generates a unique puzzle based on the date as seed.
class DailyChallengeService {
  DailyChallengeService._();
  static final instance = DailyChallengeService._();

  /// Generate today's daily challenge puzzle
  CountiqPuzzle getTodayPuzzle() {
    final now = DateTime.now();
    return _generateForDate(now.year, now.month, now.day);
  }

  /// Check if today's challenge has been completed
  bool get isTodayCompleted {
    final db = LocalDatabase.instance;
    final today = _todayKey();
    return db.getStat('daily_$today') > 0;
  }

  /// Get current streak
  int get streak {
    final db = LocalDatabase.instance;
    int count = 0;
    var date = DateTime.now();

    // If today is completed, count from today
    // If not, count from yesterday
    if (!isTodayCompleted) {
      date = date.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = _dateKey(date);
      if (db.getStat('daily_$key') > 0) {
        count++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return count;
  }

  /// Mark today as completed and save stats
  Future<void> completeTodayChallenge({
    required int timeSeconds,
    required int steps,
    required int hints,
    required int stars,
  }) async {
    final db = LocalDatabase.instance;
    final today = _todayKey();

    // Only save if not already completed today
    if (db.getStat('daily_$today') == 0) {
      await db.settingsBox.put('daily_$today', 1);
      await db.settingsBox.put('daily_${today}_time', timeSeconds);
      await db.settingsBox.put('daily_${today}_stars', stars);
      await db.settingsBox.put('daily_${today}_steps', steps);

      // Update streak tracking
      final currentStreak = streak;
      final bestStreak = db.getStat('daily_best_streak');
      if (currentStreak > bestStreak) {
        await db.settingsBox.put('daily_best_streak', currentStreak);
      }
    }
  }

  /// Get today's result (null if not completed)
  Map<String, int>? getTodayResult() {
    final db = LocalDatabase.instance;
    final today = _todayKey();
    if (db.getStat('daily_$today') == 0) return null;

    return {
      'time': db.settingsBox.get('daily_${today}_time', defaultValue: 0),
      'stars': db.settingsBox.get('daily_${today}_stars', defaultValue: 1),
      'steps': db.settingsBox.get('daily_${today}_steps', defaultValue: 0),
    };
  }

  int get bestStreak => LocalDatabase.instance.getStat('daily_best_streak');

  String _todayKey() {
    final now = DateTime.now();
    return _dateKey(now);
  }

  String _dateKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }

  /// Generate a deterministic puzzle for a specific date
  CountiqPuzzle _generateForDate(int year, int month, int day) {
    final seed = year * 10000 + month * 100 + day;

    // Daily challenges are medium-hard difficulty
    for (int attempt = 0; attempt < 100; attempt++) {
      final rng = Random(seed + attempt * 997);

      // Mix of big and small numbers (always 6 numbers for daily)
      final numbers = <int>[];
      final bigPool = [25, 50, 75, 100]..shuffle(rng);
      numbers.add(bigPool[0]);
      numbers.add(bigPool[1]);

      final smallPool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      smallPool.shuffle(rng);
      for (int i = 0; i < 4; i++) {
        numbers.add(smallPool[i]);
      }
      numbers.shuffle(rng);

      // Target: 100-999 (challenging but achievable)
      final target = 100 + rng.nextInt(900);

      final solution = PuzzleSolver.findOneSolution(numbers, target);
      if (solution != null) {
        return CountiqPuzzle(
          target: target,
          numbers: numbers,
          difficulty: 'daily',
          knownSolution: solution,
        );
      }
    }

    // Fallback: simpler target
    final rng = Random(seed);
    final numbers = [75, 50, rng.nextInt(10) + 1, rng.nextInt(10) + 1, rng.nextInt(10) + 1, rng.nextInt(10) + 1];
    final target = numbers[0] + numbers[2] * numbers[3];
    return CountiqPuzzle(
      target: target,
      numbers: numbers,
      difficulty: 'daily',
      knownSolution: Solution(steps: [
        CalcStep(num1: numbers[2], operator: '×', num2: numbers[3], result: numbers[2] * numbers[3]),
        CalcStep(num1: numbers[0], operator: '+', num2: numbers[2] * numbers[3], result: target),
      ]),
    );
  }
}
