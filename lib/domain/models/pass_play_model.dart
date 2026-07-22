import '../models/puzzle_model.dart';

/// Represents a player in Pass & Play mode.
class PassPlayPlayer {
  final String name;
  int totalScore;

  PassPlayPlayer({required this.name, this.totalScore = 0});
}

/// Stores one player's result for a single round.
class PassPlayTurnResult {
  final bool solved;
  final int timeSeconds;
  final int steps;
  final int hintsUsed;
  final int score;

  const PassPlayTurnResult({
    required this.solved,
    required this.timeSeconds,
    required this.steps,
    required this.hintsUsed,
    required this.score,
  });
}

/// One round in a Pass & Play session.
class PassPlayRound {
  final CountiqPuzzle puzzle;
  final Map<int, PassPlayTurnResult> results; // playerIndex -> result

  PassPlayRound({required this.puzzle}) : results = {};

  bool get isComplete => results.isNotEmpty;
}

/// The full session state for a Pass & Play game.
class PassPlaySession {
  final List<PassPlayPlayer> players;
  final int totalRounds;
  final String difficulty;
  final int timeLimitSeconds; // 0 = no limit
  final List<PassPlayRound> rounds;
  int currentRound;
  int currentPlayerIndex;

  PassPlaySession({
    required this.players,
    required this.totalRounds,
    required this.difficulty,
    this.timeLimitSeconds = 120,
  })  : rounds = [],
        currentRound = 0,
        currentPlayerIndex = 0;

  PassPlayPlayer get currentPlayer => players[currentPlayerIndex];

  bool get isSessionComplete => currentRound >= totalRounds;

  /// Calculate score for a turn result.
  static int calculateScore({
    required bool solved,
    required int timeSeconds,
    required int steps,
    required int hintsUsed,
    required int timeLimitSeconds,
  }) {
    if (!solved) return 0;
    // Base score for solving
    int score = 1000;
    // Time bonus (max 500): faster = more
    if (timeLimitSeconds > 0) {
      final timeRatio = 1.0 - (timeSeconds / timeLimitSeconds).clamp(0.0, 1.0);
      score += (timeRatio * 500).round();
    } else {
      // No limit: give bonus for solving under 60 sec
      final timeBonus = (1.0 - (timeSeconds / 120).clamp(0.0, 1.0)) * 500;
      score += timeBonus.round();
    }
    // Steps bonus (max 300): fewer steps = more
    final stepsBonus = (1.0 - ((steps - 1) / 5).clamp(0.0, 1.0)) * 300;
    score += stepsBonus.round();
    // Hint penalty
    score -= hintsUsed * 200;
    return score.clamp(0, 1800);
  }
}
