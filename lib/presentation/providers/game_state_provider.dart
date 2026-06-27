import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/puzzle_model.dart';
import '../../core/engine/puzzle_generator.dart';
import '../../core/engine/puzzle_solver.dart';

/// Game state for a CountiQ round
class GameState {
  final CountiqPuzzle puzzle;

  /// Numbers currently available on the board
  final List<BoardNumber> boardNumbers;

  /// Steps the player has taken
  final List<CalcStep> steps;

  /// Currently selected first number index (in boardNumbers)
  final int? selectedFirstIndex;

  /// Currently selected operator
  final String? selectedOperator;

  /// Timer elapsed seconds
  final int elapsedSeconds;

  /// Is the puzzle solved?
  final bool isSolved;

  /// Hints used count
  final int hintsUsed;

  /// Stars earned (0 if not solved)
  final int stars;

  /// Error message to display
  final String? errorMessage;

  const GameState({
    required this.puzzle,
    required this.boardNumbers,
    this.steps = const [],
    this.selectedFirstIndex,
    this.selectedOperator,
    this.elapsedSeconds = 0,
    this.isSolved = false,
    this.hintsUsed = 0,
    this.stars = 0,
    this.errorMessage,
  });

  GameState copyWith({
    CountiqPuzzle? puzzle,
    List<BoardNumber>? boardNumbers,
    List<CalcStep>? steps,
    int? Function()? selectedFirstIndex,
    String? Function()? selectedOperator,
    int? elapsedSeconds,
    bool? isSolved,
    int? hintsUsed,
    int? stars,
    String? Function()? errorMessage,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      boardNumbers: boardNumbers ?? this.boardNumbers,
      steps: steps ?? this.steps,
      selectedFirstIndex: selectedFirstIndex != null ? selectedFirstIndex() : this.selectedFirstIndex,
      selectedOperator: selectedOperator != null ? selectedOperator() : this.selectedOperator,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isSolved: isSolved ?? this.isSolved,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      stars: stars ?? this.stars,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  /// Calculate stars based on time and hints
  int calculateStars() {
    if (!isSolved) return 0;
    if (hintsUsed == 0 && elapsedSeconds <= 30) return 3;
    if (hintsUsed <= 1 && elapsedSeconds <= 60) return 2;
    return 1;
  }
}

/// Represents a number on the game board
class BoardNumber {
  final int value;
  final bool isUsed;
  final bool isResult; // Was this produced by a calculation?
  final int id; // Unique identifier for tracking

  const BoardNumber({
    required this.value,
    this.isUsed = false,
    this.isResult = false,
    required this.id,
  });

  BoardNumber copyWith({bool? isUsed, bool? isResult}) {
    return BoardNumber(
      value: value,
      isUsed: isUsed ?? this.isUsed,
      isResult: isResult ?? this.isResult,
      id: id,
    );
  }
}

/// StateNotifier for managing the game
class GameStateNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  int _nextBoardId = 100;

  // Undo stack: stores previous board states
  final List<_UndoSnapshot> _undoStack = [];

  GameStateNotifier({String difficulty = 'easy'})
      : super(GameState(
          puzzle: PuzzleGenerator.generate(difficulty: difficulty),
          boardNumbers: [],
        )) {
    _initBoard();
    _startTimer();
  }

  void _initBoard() {
    final numbers = state.puzzle.numbers
        .asMap()
        .entries
        .map((e) => BoardNumber(value: e.value, id: e.key))
        .toList();
    state = state.copyWith(boardNumbers: numbers);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isSolved) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  /// Select a number on the board
  void selectNumber(int boardIndex) {
    if (state.isSolved) return;
    final bn = state.boardNumbers[boardIndex];
    if (bn.isUsed) return;

    // Clear error
    state = state.copyWith(errorMessage: () => null);

    if (state.selectedFirstIndex == null) {
      // Selecting the first number
      state = state.copyWith(selectedFirstIndex: () => boardIndex);
    } else if (state.selectedOperator != null) {
      // We have first number + operator, now selecting second number
      if (boardIndex == state.selectedFirstIndex) {
        // Can't use same number tile
        return;
      }
      _performCalculation(boardIndex);
    } else {
      // Selecting a different first number
      if (boardIndex == state.selectedFirstIndex) {
        // Deselect
        state = state.copyWith(selectedFirstIndex: () => null);
      } else {
        state = state.copyWith(selectedFirstIndex: () => boardIndex);
      }
    }
  }

  /// Select an operator
  void selectOperator(String op) {
    if (state.isSolved) return;
    if (state.selectedFirstIndex == null) return;

    state = state.copyWith(
      selectedOperator: () => op,
      errorMessage: () => null,
    );
  }

  void _performCalculation(int secondIndex) {
    final firstIndex = state.selectedFirstIndex!;
    final op = state.selectedOperator!;
    final a = state.boardNumbers[firstIndex].value;
    final b = state.boardNumbers[secondIndex].value;

    final result = PuzzleSolver.validateStep(a, op, b);

    if (result == null) {
      // Invalid operation
      String errMsg;
      if (op == '÷' && b == 0) {
        errMsg = 'Cannot divide by zero';
      } else if (op == '÷') {
        errMsg = '$a ÷ $b is not a whole number';
      } else if (op == '-') {
        errMsg = '$a − $b would be negative or zero';
      } else {
        errMsg = 'Invalid operation';
      }
      state = state.copyWith(
        selectedFirstIndex: () => null,
        selectedOperator: () => null,
        errorMessage: () => errMsg,
      );
      return;
    }

    // Save undo snapshot
    _undoStack.add(_UndoSnapshot(
      boardNumbers: List.from(state.boardNumbers),
      steps: List.from(state.steps),
    ));

    final step = CalcStep(num1: a, operator: op, num2: b, result: result);

    // Update board: mark both numbers as used, add result
    final newBoard = List<BoardNumber>.from(state.boardNumbers);
    newBoard[firstIndex] = newBoard[firstIndex].copyWith(isUsed: true);
    newBoard[secondIndex] = newBoard[secondIndex].copyWith(isUsed: true);
    newBoard.add(BoardNumber(value: result, isResult: true, id: _nextBoardId++));

    final newSteps = [...state.steps, step];

    // Check if target reached
    final solved = result == state.puzzle.target;

    state = state.copyWith(
      boardNumbers: newBoard,
      steps: newSteps,
      selectedFirstIndex: () => null,
      selectedOperator: () => null,
      isSolved: solved,
      stars: solved ? state.calculateStars() : 0,
      errorMessage: () => null,
    );

    if (solved) {
      _timer?.cancel();
      // Recalculate stars now that we know it's solved
      final stars = state.calculateStars();
      state = state.copyWith(stars: stars > 0 ? stars : 1, isSolved: true);
    }
  }

  /// Undo the last step
  bool get canUndo => _undoStack.isNotEmpty;

  void undo() {
    if (_undoStack.isEmpty || state.isSolved) return;

    final snapshot = _undoStack.removeLast();
    state = state.copyWith(
      boardNumbers: snapshot.boardNumbers,
      steps: snapshot.steps,
      selectedFirstIndex: () => null,
      selectedOperator: () => null,
      errorMessage: () => null,
    );
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(
      selectedFirstIndex: () => null,
      selectedOperator: () => null,
      errorMessage: () => null,
    );
  }

  /// Use a hint: reveal the first step of the known solution
  void useHint() {
    if (state.isSolved) return;
    final solution = state.puzzle.knownSolution;
    if (solution == null || solution.steps.isEmpty) return;

    // Find the next unhinted step
    final hintStepIndex = state.hintsUsed;
    if (hintStepIndex >= solution.steps.length) return;

    state = state.copyWith(hintsUsed: state.hintsUsed + 1);
  }

  /// Get hint text for the current hint level
  String? getHintText() {
    final solution = state.puzzle.knownSolution;
    if (solution == null || solution.steps.isEmpty) return null;

    final hintIndex = state.hintsUsed - 1;
    if (hintIndex < 0 || hintIndex >= solution.steps.length) return null;

    final step = solution.steps[hintIndex];
    return 'Try: ${step.num1} ${step.operator} ${step.num2}';
  }

  /// Reset the current puzzle
  void resetPuzzle() {
    _undoStack.clear();
    _timer?.cancel();
    state = GameState(
      puzzle: state.puzzle,
      boardNumbers: state.puzzle.numbers
          .asMap()
          .entries
          .map((e) => BoardNumber(value: e.value, id: e.key))
          .toList(),
    );
    _nextBoardId = 100;
    _startTimer();
  }

  /// Load a new puzzle
  void newPuzzle({String difficulty = 'easy'}) {
    _undoStack.clear();
    _timer?.cancel();
    _nextBoardId = 100;
    final puzzle = PuzzleGenerator.generate(difficulty: difficulty);
    state = GameState(
      puzzle: puzzle,
      boardNumbers: puzzle.numbers
          .asMap()
          .entries
          .map((e) => BoardNumber(value: e.value, id: e.key))
          .toList(),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _UndoSnapshot {
  final List<BoardNumber> boardNumbers;
  final List<CalcStep> steps;

  const _UndoSnapshot({required this.boardNumbers, required this.steps});
}

/// Provider for the game state
final gameStateProvider =
    StateNotifierProvider.autoDispose<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

/// Provider factory for specific difficulty
final gameWithDifficultyProvider = StateNotifierProvider.autoDispose
    .family<GameStateNotifier, GameState, String>((ref, difficulty) {
  return GameStateNotifier(difficulty: difficulty);
});
