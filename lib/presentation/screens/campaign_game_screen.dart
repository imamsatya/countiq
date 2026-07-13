import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/engine/campaign_generator.dart';
import '../../core/engine/puzzle_solver.dart';
import '../../domain/models/puzzle_model.dart';
import '../../data/datasources/local_database.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/game_state_provider.dart';

/// Campaign game screen — plays a specific level number and saves progress
class CampaignGameScreen extends StatefulWidget {
  final int levelNumber;
  const CampaignGameScreen({super.key, required this.levelNumber});

  @override
  State<CampaignGameScreen> createState() => _CampaignGameScreenState();
}

class _CampaignGameScreenState extends State<CampaignGameScreen>
    with TickerProviderStateMixin {
  late CountiqPuzzle _puzzle;
  late List<BoardNumber> _boardNumbers;
  final List<CalcStep> _steps = [];
  final List<_UndoSnapshot> _undoStack = [];
  int? _selectedFirstIndex;
  String? _selectedOperator;
  int _elapsedSeconds = 0;
  bool _isSolved = false;
  int _hintsUsed = 0;
  String? _errorMessage;
  Timer? _timer;
  int _nextId = 100;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _puzzle = CampaignGenerator.generateLevel(widget.levelNumber);
    _initBoard();
    _startTimer();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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

    _undoStack.add(_UndoSnapshot(
      boardNumbers: _boardNumbers.toList(),
      steps: _steps.toList(),
    ));

    final step = CalcStep(num1: a, operator: _selectedOperator!, num2: b, result: result);
    final newBoard = List<BoardNumber>.from(_boardNumbers);
    newBoard[_selectedFirstIndex!] = newBoard[_selectedFirstIndex!].copyWith(isUsed: true);
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
        _saveProgress();
      }
    });
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

  int _calculateStars() {
    if (!_isSolved) return 0;
    if (_hintsUsed == 0 && _elapsedSeconds <= 30) return 3;
    if (_hintsUsed <= 1 && _elapsedSeconds <= 60) return 2;
    return 1;
  }

  Future<void> _saveProgress() async {
    final stars = _calculateStars();
    await LocalDatabase.instance.saveLevelCompletion(
      levelNumber: widget.levelNumber,
      stars: stars > 0 ? stars : 1,
      timeSeconds: _elapsedSeconds,
      steps: _steps.length,
      hints: _hintsUsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTargetDisplay(),
              const SizedBox(height: 12),
              Expanded(flex: 3, child: _buildStepsHistory()),
              if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 8),
              _buildNumberTiles(),
              const SizedBox(height: 12),
              _buildOperatorButtons(),
              const SizedBox(height: 12),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final diffColor = widget.levelNumber <= 30
        ? AppTheme.easyColor
        : widget.levelNumber <= 70
            ? AppTheme.mediumColor
            : AppTheme.hardColor;
    final diffLabel = widget.levelNumber <= 30
        ? 'EASY'
        : widget.levelNumber <= 70
            ? 'MEDIUM'
            : 'HARD';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Level ${widget.levelNumber}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(diffLabel,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: diffColor)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(_formatTime(_elapsedSeconds),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _isSolved ? 1.0 : (_isClose() ? _pulseAnimation.value : 1.0),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _isSolved
              ? const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF00897B)])
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
              ? [BoxShadow(color: AppTheme.successColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -2)]
              : null,
        ),
        child: Column(
          children: [
            Text(_isSolved ? '🎉 ${AppStrings.targetReached.toUpperCase()}' : AppStrings.target.toUpperCase(),
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2,
                  color: _isSolved ? Colors.white : AppTheme.textSecondary.withValues(alpha: 0.7),
                )),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => (_isSolved
                      ? const LinearGradient(colors: [Colors.white, Color(0xFFE0F7FA)])
                      : AppTheme.accentGradient)
                  .createShader(bounds),
              child: Text('${_puzzle.target}',
                  style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsHistory() {
    if (_steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded, color: AppTheme.textMuted.withValues(alpha: 0.3), size: 36),
            const SizedBox(height: 8),
            Text('Tap a number to start',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted.withValues(alpha: 0.5))),
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
          final isLast = index == _steps.length - 1;
          final hitTarget = step.result == _puzzle.target;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: hitTarget
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor.withValues(alpha: isLast ? 0.6 : 0.3),
              border: Border.all(
                color: hitTarget ? AppTheme.successColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: hitTarget ? AppTheme.successColor : AppTheme.primaryColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${step.num1} ${step.operator} ${step.num2} = ${step.result}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                          color: hitTarget ? AppTheme.successColor : Colors.white)),
                ),
                if (hitTarget) const Icon(Icons.check_circle_rounded, color: AppTheme.successColor, size: 20),
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
          const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 16),
          const SizedBox(width: 8),
          Flexible(child: Text(message, style: const TextStyle(fontSize: 12, color: AppTheme.errorColor, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildNumberTiles() {
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
            onTap: bn.isUsed ? null : () { _selectNumber(index); HapticFeedback.lightImpact(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64, height: 64,
              decoration: AppTheme.tileDeco(selected: isSelected, used: bn.isUsed, isResult: bn.isResult),
              child: Center(
                child: Text('${bn.value}',
                    style: TextStyle(
                      fontSize: bn.value >= 100 ? 18 : 22,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                      color: bn.isUsed ? AppTheme.textMuted.withValues(alpha: 0.3)
                          : isSelected ? AppTheme.primaryColor
                          : bn.isResult ? AppTheme.successColor : Colors.white,
                      decoration: bn.isUsed ? TextDecoration.lineThrough : null,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorButtons() {
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
            onTap: isEnabled ? () { _selectOperator(opMap[op.$1]!); HapticFeedback.selectionClick(); } : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected ? op.$2.withValues(alpha: 0.25) : AppTheme.surfaceColor.withValues(alpha: isEnabled ? 0.6 : 0.3),
                border: Border.all(
                  color: isSelected ? op.$2.withValues(alpha: 0.6) : Colors.white.withValues(alpha: isEnabled ? 0.1 : 0.03),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: op.$2.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: -2)] : null,
              ),
              child: Center(
                child: Text(op.$1, style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: isSelected ? op.$2 : isEnabled ? Colors.white.withValues(alpha: 0.8) : AppTheme.textMuted.withValues(alpha: 0.3),
                )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Hint
          Expanded(
            child: GestureDetector(
              onTap: _isSolved ? null : () {
                setState(() => _hintsUsed++);
                final sol = _puzzle.knownSolution;
                if (sol != null && _hintsUsed - 1 < sol.steps.length) {
                  final step = sol.steps[_hintsUsed - 1];
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Try: ${step.num1} ${step.operator} ${step.num2}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 3),
                  ));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppTheme.glassDecoration(borderRadius: 14, borderColor: AppTheme.primaryColor.withValues(alpha: 0.3)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 6),
                  Text('Hint', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Undo
          GestureDetector(
            onTap: _undoStack.isNotEmpty && !_isSolved ? () { _undo(); HapticFeedback.lightImpact(); } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(Icons.undo_rounded,
                  color: _undoStack.isNotEmpty ? AppTheme.textSecondary : AppTheme.textSecondary.withValues(alpha: 0.3), size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // Reset
          GestureDetector(
            onTap: _steps.isNotEmpty && !_isSolved ? () { _reset(); HapticFeedback.mediumImpact(); } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: Icon(Icons.refresh_rounded,
                  color: _steps.isNotEmpty ? Colors.orangeAccent : AppTheme.textSecondary.withValues(alpha: 0.3), size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // Next / Result
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSolved) {
                  context.push('/result', extra: {
                    'time': _elapsedSeconds, 'steps': _steps.length,
                    'hints': _hintsUsed, 'stars': _calculateStars(),
                    'difficulty': _puzzle.difficulty, 'target': _puzzle.target,
                    'levelNumber': widget.levelNumber,
                    'solutionSteps': _steps.toList(),
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: _isSolved
                    ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                    : AppTheme.glassDecoration(borderRadius: 14),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_isSolved ? Icons.arrow_forward_rounded : Icons.lock_rounded,
                      color: _isSolved ? AppTheme.backgroundDark : AppTheme.textSecondary.withValues(alpha: 0.3), size: 22),
                  const SizedBox(width: 4),
                  Text(_isSolved ? AppStrings.result : AppStrings.skip,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: _isSolved ? AppTheme.backgroundDark : AppTheme.textSecondary.withValues(alpha: 0.3))),
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

class _UndoSnapshot {
  final List<BoardNumber> boardNumbers;
  final List<CalcStep> steps;
  const _UndoSnapshot({required this.boardNumbers, required this.steps});
}
