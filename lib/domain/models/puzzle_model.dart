import 'package:equatable/equatable.dart';

/// Represents a single calculation step
class CalcStep extends Equatable {
  final int num1;
  final String operator;
  final int num2;
  final int result;

  const CalcStep({
    required this.num1,
    required this.operator,
    required this.num2,
    required this.result,
  });

  @override
  List<Object?> get props => [num1, operator, num2, result];

  @override
  String toString() => '$num1 $operator $num2 = $result';
}

/// Represents a complete solution (sequence of steps)
class Solution extends Equatable {
  final List<CalcStep> steps;

  const Solution({required this.steps});

  @override
  List<Object?> get props => [steps];
}

/// Represents a CountiQ puzzle
class CountiqPuzzle extends Equatable {
  /// The target number to reach
  final int target;

  /// The available numbers to use
  final List<int> numbers;

  /// Difficulty level: 'easy', 'medium', 'hard'
  final String difficulty;

  /// At least one known solution (for hint system)
  final Solution? knownSolution;

  const CountiqPuzzle({
    required this.target,
    required this.numbers,
    required this.difficulty,
    this.knownSolution,
  });

  @override
  List<Object?> get props => [target, numbers, difficulty, knownSolution];
}
