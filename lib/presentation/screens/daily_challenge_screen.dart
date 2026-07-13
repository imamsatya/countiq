import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/engine/puzzle_solver.dart';
import '../../core/services/daily_challenge_service.dart';
import '../../domain/models/puzzle_model.dart';
import '../providers/game_state_provider.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  late CountiqPuzzle _puzzle;
  late List<BoardNumber> _boardNumbers;
  final List<CalcStep> _steps = [];
  final List<_UndoSnap> _undoStack = [];
  int? _selectedFirstIndex;
  String? _selectedOperator;
  int _elapsedSeconds = 0;
  bool _isSolved = false;
  int _hintsUsed = 0;
  String? _errorMessage;
  Timer? _timer;
  int _nextId = 100;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _puzzle = DailyChallengeService.instance.getTodayPuzzle();
    _initBoard();

    // If already completed, show completed state
    if (DailyChallengeService.instance.isTodayCompleted) {
      _isSolved = true;
    } else {
      _startTimer();
    }

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _initBoard() {
    _boardNumbers = _puzzle.numbers
        .asMap()
        .entries
        .map((e) => BoardNumber(value: e.value, id: e.key))
        .toList();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isSolved) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectNumber(int index) {
    if (_isSolved || _boardNumbers[index].isUsed) return;
    setState(() {
      _errorMessage = null;
      if (_selectedFirstIndex == null) {
        _selectedFirstIndex = index;
      } else if (_selectedOperator != null) {
        if (index == _selectedFirstIndex) return;
        _performCalculation(index);
      } else {
        _selectedFirstIndex = index == _selectedFirstIndex ? null : index;
      }
    });
  }

  void _selectOperator(String op) {
    if (_isSolved || _selectedFirstIndex == null) return;
    setState(() {
      _selectedOperator = op;
      _errorMessage = null;
    });
  }

  void _performCalculation(int secondIndex) {
    final a = _boardNumbers[_selectedFirstIndex!].value;
    final b = _boardNumbers[secondIndex].value;
    final result = PuzzleSolver.validateStep(a, _selectedOperator!, b);

    if (result == null) {
      setState(() {
        if (_selectedOperator == '÷' && b == 0) {
          _errorMessage = 'Cannot divide by zero';
        } else if (_selectedOperator == '÷') {
          _errorMessage = '$a ÷ $b is not a whole number';
        } else if (_selectedOperator == '-') {
          _errorMessage = '$a − $b would be negative or zero';
        } else {
          _errorMessage = 'Invalid operation';
        }
        _selectedFirstIndex = null;
        _selectedOperator = null;
      });
      return;
    }

    _undoStack.add(_UndoSnap(
      boardNumbers: _boardNumbers.toList(),
      steps: _steps.toList(),
    ));

    final step = CalcStep(
        num1: a, operator: _selectedOperator!, num2: b, result: result);
    final newBoard = List<BoardNumber>.from(_boardNumbers);
    newBoard[_selectedFirstIndex!] =
        newBoard[_selectedFirstIndex!].copyWith(isUsed: true);
    newBoard[secondIndex] = newBoard[secondIndex].copyWith(isUsed: true);
    newBoard.add(BoardNumber(value: result, isResult: true, id: _nextId++));

    setState(() {
      _boardNumbers = newBoard;
      _steps.add(step);
      _selectedFirstIndex = null;
      _selectedOperator = null;
      _errorMessage = null;

      if (result == _puzzle.target) {
        _isSolved = true;
        _timer?.cancel();
        _saveCompletion();
      }
    });
  }

  int _calculateStars() {
    if (!_isSolved) return 0;
    if (_hintsUsed == 0 && _elapsedSeconds <= 30) return 3;
    if (_hintsUsed <= 1 && _elapsedSeconds <= 60) return 2;
    return 1;
  }

  Future<void> _saveCompletion() async {
    await DailyChallengeService.instance.completeTodayChallenge(
      timeSeconds: _elapsedSeconds,
      steps: _steps.length,
      hints: _hintsUsed,
      stars: _calculateStars(),
    );
  }

  void _undo() {
    if (_undoStack.isEmpty || _isSolved) return;
    final snap = _undoStack.removeLast();
    setState(() {
      _boardNumbers = snap.boardNumbers;
      _steps.clear();
      _steps.addAll(snap.steps);
      _selectedFirstIndex = null;
      _selectedOperator = null;
      _errorMessage = null;
    });
  }

  void _reset() {
    if (_isSolved) return;
    _undoStack.clear();
    setState(() {
      _initBoard();
      _steps.clear();
      _selectedFirstIndex = null;
      _selectedOperator = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final streak = DailyChallengeService.instance.streak;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, dateStr, streak),
              const SizedBox(height: 8),

              // Target
              _buildTargetDisplay(),
              const SizedBox(height: 12),

              // Steps
              Expanded(flex: 3, child: _buildStepsHistory()),

              if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 8),

              // Numbers
              _buildNumberTiles(),
              const SizedBox(height: 12),

              // Operators
              _buildOperatorButtons(),
              const SizedBox(height: 12),

              // Actions
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String dateStr, int streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.today_rounded,
                    color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          const Spacer(),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Text('🔥 $streak',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            )
          else
            const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    final pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) => Transform.scale(
        scale: _isSolved ? 1.0 : (_isClose() ? pulse.value : 1.0),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _isSolved
              ? const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF00897B)])
              : LinearGradient(colors: [
                  AppTheme.surfaceColor.withValues(alpha: 0.8),
                  AppTheme.surfaceLight.withValues(alpha: 0.6),
                ]),
          border: Border.all(
            color: _isSolved
                ? AppTheme.successColor.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: _isSolved
              ? [BoxShadow(color: AppTheme.successColor.withValues(alpha: 0.3), blurRadius: 20)]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSolved ? '🎉 DAILY COMPLETE!' : '📅 DAILY CHALLENGE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: _isSolved
                        ? Colors.white
                        : AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => (_isSolved
                      ? const LinearGradient(
                          colors: [Colors.white, Color(0xFFE0F7FA)])
                      : AppTheme.accentGradient)
                  .createShader(bounds),
              child: Text('${_puzzle.target}',
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsHistory() {
    if (_steps.isEmpty && !_isSolved) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded,
                color: AppTheme.textMuted.withValues(alpha: 0.3), size: 36),
            const SizedBox(height: 8),
            Text('Tap a number to start',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted.withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    // Show completed message if already done
    if (_isSolved && _steps.isEmpty) {
      final result = DailyChallengeService.instance.getTodayResult();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text("Today's challenge completed!",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor)),
            if (result != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(3, (i) => Icon(
                    i < (result['stars'] ?? 1)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: i < (result['stars'] ?? 1)
                        ? const Color(0xFFFFD700)
                        : AppTheme.textMuted.withValues(alpha: 0.3),
                    size: 24,
                  )),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Time: ${_formatTime(result['time'] ?? 0)} • Steps: ${result['steps'] ?? 0}',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              ),
            ],
            const SizedBox(height: 16),
            Text('Come back tomorrow for a new challenge!',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted.withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: _steps.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, index) {
          final step = _steps[index];
          final hitTarget = step.result == _puzzle.target;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: hitTarget
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor
                      .withValues(alpha: index == _steps.length - 1 ? 0.6 : 0.3),
              border: Border.all(
                  color: hitTarget
                      ? AppTheme.successColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hitTarget
                        ? AppTheme.successColor.withValues(alpha: 0.2)
                        : AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                      child: Text('${index + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hitTarget
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor))),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        '${step.num1} ${step.operator} ${step.num2} = ${step.result}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: hitTarget
                                ? AppTheme.successColor
                                : Colors.white))),
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
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.errorColor, size: 16),
          const SizedBox(width: 8),
          Flexible(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildNumberTiles() {
    if (_isSolved && _steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _boardNumbers.asMap().entries.map((entry) {
          final index = entry.key;
          final bn = entry.value;
          final isSelected = _selectedFirstIndex == index;
          return GestureDetector(
            onTap: bn.isUsed || _isSolved
                ? null
                : () {
                    _selectNumber(index);
                    HapticFeedback.lightImpact();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64, height: 64,
              decoration: AppTheme.tileDeco(
                  selected: isSelected, used: bn.isUsed, isResult: bn.isResult),
              child: Center(
                  child: Text('${bn.value}',
                      style: TextStyle(
                        fontSize: bn.value >= 100 ? 18 : 22,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                        color: bn.isUsed
                            ? AppTheme.textMuted.withValues(alpha: 0.3)
                            : isSelected
                                ? AppTheme.primaryColor
                                : bn.isResult
                                    ? AppTheme.successColor
                                    : Colors.white,
                        decoration:
                            bn.isUsed ? TextDecoration.lineThrough : null,
                      ))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorButtons() {
    if (_isSolved && _steps.isEmpty) return const SizedBox.shrink();

    final operators = [
      ('+', AppTheme.operatorAdd), ('−', AppTheme.operatorSub),
      ('×', AppTheme.operatorMul), ('÷', AppTheme.operatorDiv),
    ];
    const opMap = {'+': '+', '−': '-', '×': '×', '÷': '÷'};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: operators.map((op) {
          final isSelected = _selectedOperator == opMap[op.$1];
          final isEnabled = _selectedFirstIndex != null && !_isSolved;
          return GestureDetector(
            onTap: isEnabled
                ? () {
                    _selectOperator(opMap[op.$1]!);
                    HapticFeedback.selectionClick();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? op.$2.withValues(alpha: 0.25)
                    : AppTheme.surfaceColor
                        .withValues(alpha: isEnabled ? 0.6 : 0.3),
                border: Border.all(
                  color: isSelected
                      ? op.$2.withValues(alpha: 0.6)
                      : Colors.white
                          .withValues(alpha: isEnabled ? 0.1 : 0.03),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: op.$2.withValues(alpha: 0.3), blurRadius: 12)]
                    : null,
              ),
              child: Center(
                  child: Text(op.$1,
                      style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: isSelected
                            ? op.$2
                            : isEnabled
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppTheme.textMuted.withValues(alpha: 0.3),
                      ))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isSolved && _steps.isEmpty) {
      // Already completed — show home button
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: AppTheme.primaryGlowDecoration(borderRadius: 14),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, color: Color(0xFF0A0E1A), size: 22),
                SizedBox(width: 8),
                Text('Back to Home',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0E1A))),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Hint
          Expanded(
            child: GestureDetector(
              onTap: _isSolved
                  ? null
                  : () {
                      setState(() => _hintsUsed++);
                      final sol = _puzzle.knownSolution;
                      if (sol != null && _hintsUsed - 1 < sol.steps.length) {
                        final step = sol.steps[_hintsUsed - 1];
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                    'Try: ${step.num1} ${step.operator} ${step.num2}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ]),
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 3),
                        ));
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.glassDecoration(
                    borderRadius: 14,
                    borderColor: AppTheme.primaryColor.withValues(alpha: 0.3)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 6),
                      Text('Hint',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor)),
                    ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Undo
          GestureDetector(
            onTap: _undoStack.isNotEmpty && !_isSolved
                ? () {
                    _undo();
                    HapticFeedback.lightImpact();
                  }
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(Icons.undo_rounded,
                  color: _undoStack.isNotEmpty
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
                  size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // Reset
          GestureDetector(
            onTap: _steps.isNotEmpty && !_isSolved
                ? () {
                    _reset();
                    HapticFeedback.mediumImpact();
                  }
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(Icons.refresh_rounded,
                  color: _steps.isNotEmpty
                      ? Colors.orangeAccent
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
                  size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // Home (when solved)
          if (_isSolved)
            Expanded(
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration:
                      AppTheme.primaryGlowDecoration(borderRadius: 14),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded,
                            color: Color(0xFF0A0E1A), size: 22),
                        SizedBox(width: 4),
                        Text('Home',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0E1A))),
                      ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isClose() {
    for (final bn in _boardNumbers) {
      if (bn.isUsed) continue;
      final diff = (bn.value - _puzzle.target).abs();
      if (diff > 0 && diff <= _puzzle.target * 0.1) return true;
    }
    return false;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _UndoSnap {
  final List<BoardNumber> boardNumbers;
  final List<CalcStep> steps;
  const _UndoSnap({required this.boardNumbers, required this.steps});
}
