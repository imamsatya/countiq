import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../providers/game_state_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _solveFlashController;
  late Animation<double> _solveFlashAnim;
  bool _prevSolved = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _solveFlashController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _solveFlashAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _solveFlashController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    _solveFlashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameWithDifficultyProvider(widget.difficulty));
    final notifier = ref.read(gameWithDifficultyProvider(widget.difficulty).notifier);

    // Trigger solve flash when puzzle is just solved
    if (gameState.isSolved && !_prevSolved) {
      _prevSolved = true;
      _solveFlashController.forward().then((_) {
        if (mounted) _solveFlashController.reverse();
      });
    } else if (!gameState.isSolved && _prevSolved) {
      // Reset when we get a new unsolved puzzle
      _prevSolved = false;
      _solveFlashController.reset();
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(gameState),
                  const SizedBox(height: 8),

                  // Target display
                  _buildTargetDisplay(gameState),
                  const SizedBox(height: 12),

                  // Steps history
                  Expanded(
                    flex: 3,
                    child: _buildStepsHistory(gameState),
                  ),

                  // Error message
                  if (gameState.errorMessage != null)
                    _buildErrorBanner(gameState.errorMessage!),

                  const SizedBox(height: 8),

                  // Number tiles
                  _buildNumberTiles(gameState, notifier),
                  const SizedBox(height: 12),

                  // Operator buttons
                  _buildOperatorButtons(gameState, notifier),
                  const SizedBox(height: 12),

                  // Action buttons
                  _buildActionButtons(gameState, notifier),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Celebration flash overlay
          if (gameState.isSolved)
            AnimatedBuilder(
              animation: _solveFlashAnim,
              builder: (context, _) {
                return IgnorePointer(
                  child: Container(
                    color: AppTheme.successColor.withValues(
                      alpha: _solveFlashAnim.value * 0.15,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),

          const Spacer(),

          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDiffEmoji(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.difficulty.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getDiffColor(),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(gameState.elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay(GameState gameState) {
    final isClose = _isCloseToTarget(gameState);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: gameState.isSolved ? 1.0 : (isClose ? _pulseAnimation.value : 1.0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gameState.isSolved
              ? const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF00897B)],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.surfaceColor.withValues(alpha: 0.8),
                    AppTheme.surfaceLight.withValues(alpha: 0.6),
                  ],
                ),
          border: Border.all(
            color: gameState.isSolved
                ? AppTheme.successColor.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (gameState.isSolved)
              BoxShadow(
                color: AppTheme.successColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: -2,
              )
            else if (isClose)
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: -2,
              ),
          ],
        ),
        child: Column(
          children: [
            Text(
              gameState.isSolved ? '🎉 TARGET REACHED!' : 'TARGET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: gameState.isSolved
                    ? Colors.white
                    : AppTheme.textSecondary.withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => (gameState.isSolved
                      ? const LinearGradient(
                          colors: [Colors.white, Color(0xFFE0F7FA)])
                      : AppTheme.accentGradient)
                  .createShader(bounds),
              child: Text(
                '${gameState.puzzle.target}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsHistory(GameState gameState) {
    if (gameState.steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a number to start',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: gameState.steps.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, index) {
          final step = gameState.steps[index];
          final isLast = index == gameState.steps.length - 1;
          final hitTarget = step.result == gameState.puzzle.target;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: hitTarget
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor.withValues(alpha: isLast ? 0.6 : 0.3),
              border: Border.all(
                color: hitTarget
                    ? AppTheme.successColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hitTarget
                        ? AppTheme.successColor.withValues(alpha: 0.2)
                        : AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hitTarget
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${step.num1} ${step.operator} ${step.num2} = ${step.result}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hitTarget ? AppTheme.successColor : Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (hitTarget)
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.successColor, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.errorColor.withValues(alpha: 0.15),
        border: Border.all(
          color: AppTheme.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.errorColor, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberTiles(GameState gameState, GameStateNotifier notifier) {
    final availableNumbers = gameState.boardNumbers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _shakeAnimation.value *
                  ((_shakeController.isAnimating && _shakeController.value > 0.5)
                      ? -1
                      : 1),
              0,
            ),
            child: child,
          );
        },
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: availableNumbers.asMap().entries.map((entry) {
            final index = entry.key;
            final bn = entry.value;
            final isSelected = gameState.selectedFirstIndex == index;

            return GestureDetector(
              onTap: bn.isUsed ? null : () {
                notifier.selectNumber(index);
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 64,
                height: 64,
                decoration: AppTheme.tileDeco(
                  selected: isSelected,
                  used: bn.isUsed,
                  isResult: bn.isResult,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: bn.value >= 100 ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: bn.isUsed
                          ? AppTheme.textMuted.withValues(alpha: 0.3)
                          : isSelected
                              ? AppTheme.primaryColor
                              : bn.isResult
                                  ? AppTheme.successColor
                                  : Colors.white,
                      decoration: bn.isUsed ? TextDecoration.lineThrough : null,
                      decorationColor: AppTheme.textMuted.withValues(alpha: 0.3),
                    ),
                    child: Text('${bn.value}'),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOperatorButtons(GameState gameState, GameStateNotifier notifier) {
    final operators = [
      ('+', AppTheme.operatorAdd, Icons.add_rounded),
      ('−', AppTheme.operatorSub, Icons.remove_rounded),
      ('×', AppTheme.operatorMul, Icons.close_rounded),
      ('÷', AppTheme.operatorDiv, Icons.safety_divider),
    ];

    // Map display symbol to internal symbol
    const opMap = {'+': '+', '−': '-', '×': '×', '÷': '÷'};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: operators.map((op) {
          final isSelected = gameState.selectedOperator == opMap[op.$1];
          final isEnabled = gameState.selectedFirstIndex != null && !gameState.isSolved;

          return GestureDetector(
            onTap: isEnabled
                ? () {
                    notifier.selectOperator(opMap[op.$1]!);
                    HapticFeedback.selectionClick();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? op.$2.withValues(alpha: 0.25)
                    : AppTheme.surfaceColor.withValues(alpha: isEnabled ? 0.6 : 0.3),
                border: Border.all(
                  color: isSelected
                      ? op.$2.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: isEnabled ? 0.1 : 0.03),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: op.$2.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: -2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  op.$1,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? op.$2
                        : isEnabled
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(GameState gameState, GameStateNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Hint button
          Expanded(
            child: GestureDetector(
              onTap: gameState.isSolved
                  ? null
                  : () {
                      notifier.useHint();
                      final hint = notifier.getHintText();
                      if (hint != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(hint,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      HapticFeedback.mediumImpact();
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.glassDecoration(
                  borderRadius: 14,
                  borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Hint',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Undo button
          GestureDetector(
            onTap: notifier.canUndo && !gameState.isSolved
                ? () {
                    notifier.undo();
                    HapticFeedback.lightImpact();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(
                Icons.undo_rounded,
                color: notifier.canUndo
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Reset button
          GestureDetector(
            onTap: gameState.steps.isNotEmpty && !gameState.isSolved
                ? () {
                    notifier.resetPuzzle();
                    HapticFeedback.mediumImpact();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(
                Icons.refresh_rounded,
                color: gameState.steps.isNotEmpty
                    ? Colors.orangeAccent
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // New puzzle / Next
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (gameState.isSolved) {
                  // Save quick play stats
                  LocalDatabase.instance.recordQuickPlay(
                    timeSeconds: gameState.elapsedSeconds,
                    steps: gameState.steps.length,
                    hints: gameState.hintsUsed,
                    difficulty: widget.difficulty,
                  );
                  // Go to result
                  context.push('/result', extra: {
                    'time': gameState.elapsedSeconds,
                    'steps': gameState.steps.length,
                    'hints': gameState.hintsUsed,
                    'stars': gameState.calculateStars(),
                    'difficulty': widget.difficulty,
                    'target': gameState.puzzle.target,
                    'solutionSteps': List.from(gameState.steps),
                  });
                } else {
                  // Skip to new puzzle
                  notifier.newPuzzle(difficulty: widget.difficulty);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: gameState.isSolved
                    ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                    : AppTheme.glassDecoration(borderRadius: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      gameState.isSolved
                          ? Icons.arrow_forward_rounded
                          : Icons.skip_next_rounded,
                      color: gameState.isSolved
                          ? AppTheme.backgroundDark
                          : AppTheme.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gameState.isSolved ? 'Result' : 'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: gameState.isSolved
                            ? AppTheme.backgroundDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCloseToTarget(GameState gameState) {
    // Check if any available number is within 10% of the target
    final target = gameState.puzzle.target;
    for (final bn in gameState.boardNumbers) {
      if (bn.isUsed) continue;
      final diff = (bn.value - target).abs();
      if (diff > 0 && diff <= target * 0.1) return true;
    }
    return false;
  }

  Color _getDiffColor() {
    switch (widget.difficulty) {
      case 'easy':
        return AppTheme.easyColor;
      case 'medium':
        return AppTheme.mediumColor;
      case 'hard':
        return AppTheme.hardColor;
      default:
        return AppTheme.easyColor;
    }
  }

  String _getDiffEmoji() {
    switch (widget.difficulty) {
      case 'easy':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'hard':
        return '🔴';
      default:
        return '🟢';
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
