import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/engine/puzzle_generator.dart';
import '../../core/engine/puzzle_solver.dart';
import '../../core/services/sound_service.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/models/puzzle_model.dart';
import '../providers/game_state_provider.dart';

class TimeAttackScreen extends StatefulWidget {
  const TimeAttackScreen({super.key});

  @override
  State<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends State<TimeAttackScreen>
    with TickerProviderStateMixin {
  // Game config
  static const int _totalSeconds = 60;

  // State
  int _remainingSeconds = _totalSeconds;
  int _puzzlesSolved = 0;
  bool _isPlaying = false;
  bool _isFinished = false;
  Timer? _timer;

  // Current puzzle
  late CountiqPuzzle _puzzle;
  late List<BoardNumber> _boardNumbers;
  final List<CalcStep> _steps = [];
  final List<_UndoSnap> _undoStack = [];
  int? _selectedFirstIndex;
  String? _selectedOperator;
  String? _errorMessage;
  int _nextId = 100;

  // Animation
  late AnimationController _countdownPulse;
  late AnimationController _solvedFlash;

  @override
  void initState() {
    super.initState();
    _puzzle = PuzzleGenerator.generate(difficulty: 'easy');
    _initBoard();

    _countdownPulse = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _solvedFlash = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _initBoard() {
    _boardNumbers = _puzzle.numbers
        .asMap()
        .entries
        .map((e) => BoardNumber(value: e.value, id: e.key))
        .toList();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _remainingSeconds = _totalSeconds;
      _puzzlesSolved = 0;
    });
    _loadNewPuzzle();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds--;
        // Pulse when low time
        if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
          _countdownPulse.forward().then((_) => _countdownPulse.reverse());
        }
        if (_remainingSeconds <= 0) {
          _endGame();
        }
      });
    });
  }

  void _loadNewPuzzle() {
    // Difficulty scales with puzzles solved
    String diff = 'easy';
    if (_puzzlesSolved >= 5) diff = 'medium';
    if (_puzzlesSolved >= 10) diff = 'hard';

    setState(() {
      _puzzle = PuzzleGenerator.generate(difficulty: diff);
      _boardNumbers = _puzzle.numbers
          .asMap()
          .entries
          .map((e) => BoardNumber(value: e.value, id: e.key))
          .toList();
      _steps.clear();
      _undoStack.clear();
      _selectedFirstIndex = null;
      _selectedOperator = null;
      _errorMessage = null;
      _nextId = 100;
    });
  }

  void _endGame() {
    _timer?.cancel();
    _isPlaying = false;
    _isFinished = true;
    SoundService.instance.playSuccess();

    // Save stats
    final db = LocalDatabase.instance;
    final bestTimeAttack = db.getStat('time_attack_best');
    if (_puzzlesSolved > bestTimeAttack) {
      db.settingsBox.put('time_attack_best', _puzzlesSolved);
    }
    db.settingsBox.put('time_attack_total_games',
        (db.getStat('time_attack_total_games') + 1));
    db.settingsBox.put('time_attack_total_solved',
        (db.getStat('time_attack_total_solved') + _puzzlesSolved));

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownPulse.dispose();
    _solvedFlash.dispose();
    super.dispose();
  }

  // ─── Game Mechanics ──────────────────────────────────────────

  void _selectNumber(int index) {
    if (!_isPlaying || _boardNumbers[index].isUsed) return;
    setState(() {
      _errorMessage = null;
      if (_selectedFirstIndex == null) {
        _selectedFirstIndex = index;
        SoundService.instance.playTap();
      } else if (_selectedOperator != null) {
        if (index == _selectedFirstIndex) return;
        _performCalculation(index);
      } else {
        _selectedFirstIndex = index == _selectedFirstIndex ? null : index;
        SoundService.instance.playTap();
      }
    });
  }

  void _selectOperator(String op) {
    if (!_isPlaying || _selectedFirstIndex == null) return;
    SoundService.instance.select();
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
      SoundService.instance.playError();
      setState(() {
        if (_selectedOperator == '÷' && b == 0) {
          _errorMessage = 'Cannot divide by zero';
        } else if (_selectedOperator == '÷') {
          _errorMessage = '$a ÷ $b is not whole';
        } else if (_selectedOperator == '-') {
          _errorMessage = '$a − $b is negative';
        } else {
          _errorMessage = 'Invalid';
        }
        _selectedFirstIndex = null;
        _selectedOperator = null;
      });
      return;
    }

    _undoStack.add(_UndoSnap(
      boardNumbers: List.from(_boardNumbers),
      steps: List.from(_steps),
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
        _puzzlesSolved++;
        SoundService.instance.playTap();

        // Flash animation
        _solvedFlash.forward().then((_) {
          _solvedFlash.reverse();
          // Add bonus time: +5 seconds per solve
          setState(() {
            _remainingSeconds = (_remainingSeconds + 5).clamp(0, 99);
          });
          _loadNewPuzzle();
        });
      } else {
        SoundService.instance.playTap();
      }
    });
  }

  void _undo() {
    if (_undoStack.isEmpty || !_isPlaying) return;
    SoundService.instance.undo();
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
    if (!_isPlaying) return;
    SoundService.instance.undo();
    _undoStack.clear();
    setState(() {
      _initBoard();
      _steps.clear();
      _selectedFirstIndex = null;
      _selectedOperator = null;
      _errorMessage = null;
    });
  }

  void _skip() {
    if (!_isPlaying) return;
    // Skip costs 5 seconds
    setState(() {
      _remainingSeconds = (_remainingSeconds - 5).clamp(0, 99);
    });
    if (_remainingSeconds <= 0) {
      _endGame();
    } else {
      _loadNewPuzzle();
    }
  }

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_isPlaying && !_isFinished) ...[
                const Spacer(flex: 2),
                _buildStartView(),
                const Spacer(flex: 3),
              ] else if (_isFinished) ...[
                const Spacer(flex: 2),
                _buildResultView(),
                const Spacer(flex: 3),
              ] else ...[
                const SizedBox(height: 8),
                _buildTargetDisplay(),
                const SizedBox(height: 8),
                Expanded(flex: 3, child: _buildStepsHistory()),
                if (_errorMessage != null) _buildErrorBanner(),
                const SizedBox(height: 8),
                _buildNumberTiles(),
                const SizedBox(height: 10),
                _buildOperatorButtons(),
                const SizedBox(height: 10),
                _buildActionButtons(),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isLow = _remainingSeconds <= 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _timer?.cancel();
              context.canPop() ? context.pop() : context.go('/');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          if (_isPlaying) ...[
            // Solved counter
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.successColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$_puzzlesSolved',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Timer
            AnimatedBuilder(
              animation: _countdownPulse,
              builder: (context, child) => Transform.scale(
                scale: isLow ? 1.0 + _countdownPulse.value * 0.1 : 1.0,
                child: child,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isLow
                      ? AppTheme.errorColor.withValues(alpha: 0.2)
                      : AppTheme.surfaceColor.withValues(alpha: 0.6),
                  border: Border.all(
                    color: isLow
                        ? AppTheme.errorColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded,
                        color: isLow
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                        size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_remainingSeconds}s',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isLow
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text(
              '⚡ TIME ATTACK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildStartView() {
    final bestScore = LocalDatabase.instance.getStat('time_attack_best');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: const Text(
              'Time Attack',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Solve as many puzzles as you can\nin 60 seconds!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.successColor.withValues(alpha: 0.1),
              border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.2)),
            ),
            child: const Text(
              '+5 seconds bonus per solve!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.successColor,
              ),
            ),
          ),
          if (bestScore > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Best: $bestScore puzzle${bestScore > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: AppTheme.primaryGlowDecoration(borderRadius: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded,
                      color: Color(0xFF0A0E1A), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'START',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0E1A),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final bestScore = LocalDatabase.instance.getStat('time_attack_best');
    final isNewBest = _puzzlesSolved >= bestScore && _puzzlesSolved > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            isNewBest ? '🎉' : '⏰',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => (isNewBest
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA726)])
                    : AppTheme.primaryGradient)
                .createShader(bounds),
            child: Text(
              isNewBest ? 'NEW BEST!' : 'TIME\'S UP!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            decoration: AppTheme.glassDecoration(borderRadius: 20),
            child: Column(
              children: [
                const Text(
                  'PUZZLES SOLVED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.accentGradient.createShader(bounds),
                  child: Text(
                    '$_puzzlesSolved',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (bestScore > 0 && !isNewBest)
                  Text(
                    'Best: $bestScore',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text: '⚡ I solved $_puzzlesSolved puzzles in Time Attack mode on CountiQ! Can you beat my score? #CountiQ #MathPuzzle',
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: AppTheme.glassDecoration(
                        borderRadius: 14,
                        borderColor:
                            AppTheme.primaryColor.withValues(alpha: 0.3)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded,
                            color: AppTheme.primaryColor, size: 18),
                        SizedBox(width: 6),
                        Text('Share',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFinished = false;
                    });
                    _startGame();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration:
                        AppTheme.primaryGlowDecoration(borderRadius: 14),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_rounded,
                            color: Color(0xFF0A0E1A), size: 20),
                        SizedBox(width: 6),
                        Text('Again',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0E1A))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 14),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded,
                      color: AppTheme.textSecondary, size: 18),
                  SizedBox(width: 6),
                  Text('Home',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return AnimatedBuilder(
      animation: _solvedFlash,
      builder: (context, child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Color.lerp(
            AppTheme.surfaceColor.withValues(alpha: 0.7),
            AppTheme.successColor.withValues(alpha: 0.3),
            _solvedFlash.value,
          ),
          border: Border.all(
            color: Color.lerp(
              AppTheme.primaryColor.withValues(alpha: 0.2),
              AppTheme.successColor.withValues(alpha: 0.5),
              _solvedFlash.value,
            )!,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              'TARGET',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.accentGradient.createShader(bounds),
              child: Text(
                '${_puzzle.target}',
                style: const TextStyle(
                  fontSize: 44,
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

  Widget _buildStepsHistory() {
    if (_steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded,
                color: AppTheme.textMuted.withValues(alpha: 0.3), size: 32),
            const SizedBox(height: 6),
            Text('Tap a number to start',
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemBuilder: (context, index) {
          final step = _steps[index];
          final hitTarget = step.result == _puzzle.target;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: hitTarget
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor.withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                Text('${index + 1}.',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted.withValues(alpha: 0.5))),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        '${step.num1} ${step.operator} ${step.num2} = ${step.result}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: hitTarget
                                ? AppTheme.successColor
                                : Colors.white))),
                if (hitTarget)
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.successColor, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.errorColor.withValues(alpha: 0.15),
      ),
      child: Text(_errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w500)),
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
            onTap:
                bn.isUsed || !_isPlaying ? null : () => _selectNumber(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60, height: 60,
              decoration: AppTheme.tileDeco(
                  selected: isSelected, used: bn.isUsed, isResult: bn.isResult),
              child: Center(
                  child: Text('${bn.value}',
                      style: TextStyle(
                        fontSize: bn.value >= 100 ? 16 : 20,
                        fontWeight: FontWeight.w700,
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
          final isEnabled = _selectedFirstIndex != null && _isPlaying;
          return GestureDetector(
            onTap: isEnabled ? () => _selectOperator(opMap[op.$1]!) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
              ),
              child: Center(
                  child: Text(op.$1,
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Skip (-5s)
          Expanded(
            child: GestureDetector(
              onTap: _isPlaying ? _skip : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: AppTheme.glassDecoration(
                    borderRadius: 12,
                    borderColor: Colors.orange.withValues(alpha: 0.3)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.skip_next_rounded,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 4),
                    Text('Skip (−5s)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Undo
          GestureDetector(
            onTap: _undoStack.isNotEmpty && _isPlaying ? _undo : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Icon(Icons.undo_rounded,
                  color: _undoStack.isNotEmpty
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
                  size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Reset
          GestureDetector(
            onTap: _steps.isNotEmpty && _isPlaying ? _reset : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Icon(Icons.refresh_rounded,
                  color: _steps.isNotEmpty
                      ? Colors.orangeAccent
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _UndoSnap {
  final List<BoardNumber> boardNumbers;
  final List<CalcStep> steps;
  const _UndoSnap({required this.boardNumbers, required this.steps});
}
