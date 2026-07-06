import '../../domain/models/puzzle_model.dart';

/// Brute-force solver for CountiQ puzzles.
/// Tries all combinations of number pairs and operations recursively.
///
/// Rules:
/// - Each number can only be used once
/// - Only +, -, *, / operations
/// - All intermediate results must be positive integers (no fractions, no negatives)
class PuzzleSolver {
  static const List<String> _operators = ['+', '-', '×', '÷'];

  /// Find all solutions for the given numbers and target.
  /// Returns up to [maxSolutions] solutions to avoid excessive computation.
  static List<Solution> solve(List<int> numbers, int target, {int maxSolutions = 5}) {
    final solutions = <Solution>[];
    final steps = <CalcStep>[];

    _solve(List<int>.from(numbers), target, steps, solutions, maxSolutions);

    return solutions;
  }

  /// Check if a puzzle is solvable (at least one solution exists)
  static bool isSolvable(List<int> numbers, int target) {
    return solve(numbers, target, maxSolutions: 1).isNotEmpty;
  }

  /// Get one solution (for hint system)
  static Solution? findOneSolution(List<int> numbers, int target) {
    final solutions = solve(numbers, target, maxSolutions: 1);
    return solutions.isNotEmpty ? solutions.first : null;
  }

  static void _solve(
    List<int> available,
    int target,
    List<CalcStep> currentSteps,
    List<Solution> solutions,
    int maxSolutions,
  ) {
    if (solutions.length >= maxSolutions) return;

    // Check if we've already reached the target
    if (available.contains(target) && currentSteps.isNotEmpty) {
      solutions.add(Solution(steps: List.from(currentSteps)));
      return;
    }

    // Need at least 2 numbers to make an operation
    if (available.length < 2) return;

    // Try all pairs of numbers
    for (int i = 0; i < available.length; i++) {
      for (int j = 0; j < available.length; j++) {
        if (i == j) continue;
        if (solutions.length >= maxSolutions) return;

        final a = available[i];
        final b = available[j];

        // Try all operators
        for (final op in _operators) {
          final result = _calculate(a, op, b);
          if (result == null) continue; // Invalid operation

          final step = CalcStep(num1: a, operator: op, num2: b, result: result);

          // Create new available list: remove a and b, add result
          final newAvailable = <int>[];
          bool removedA = false;
          bool removedB = false;
          for (int k = 0; k < available.length; k++) {
            if (k == i && !removedA) {
              removedA = true;
              continue;
            }
            if (k == j && !removedB) {
              removedB = true;
              continue;
            }
            newAvailable.add(available[k]);
          }
          newAvailable.add(result);

          currentSteps.add(step);

          // Check if we hit the target
          if (result == target) {
            solutions.add(Solution(steps: List.from(currentSteps)));
          } else {
            // Recurse with new available numbers
            _solve(newAvailable, target, currentSteps, solutions, maxSolutions);
          }

          currentSteps.removeLast();
        }
      }
    }
  }

  /// Perform a calculation for the SOLVER.
  /// Returns null if invalid OR trivial (×1, ÷1) to prune search space.
  static int? _calculate(int a, String op, int b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        if (a <= b) return null; // No zero or negative results
        return a - b;
      case '×':
        if (a <= 1 || b <= 1) return null; // Solver skips trivial ×1
        return a * b;
      case '÷':
        if (b == 0) return null;
        if (b == 1 && a == 1) return null; // 1÷1 is trivial
        if (a % b != 0) return null;
        return a ~/ b;
      default:
        return null;
    }
  }

  /// Validate a PLAYER's step.
  /// More permissive than _calculate: allows ÷1, ×1, etc.
  /// Only rejects truly invalid math (÷0, fractions, negatives/zero).
  static int? validateStep(int num1, String operator, int num2) {
    switch (operator) {
      case '+':
        return num1 + num2;
      case '-':
        if (num1 <= num2) return null; // No zero or negative results
        return num1 - num2;
      case '×':
        return num1 * num2;
      case '÷':
        if (num2 == 0) return null; // Division by zero
        if (num1 % num2 != 0) return null; // Must divide evenly
        final result = num1 ~/ num2;
        if (result <= 0) return null; // No zero or negative
        return result;
      default:
        return null;
    }
  }
}
