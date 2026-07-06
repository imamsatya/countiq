import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/achievement_service.dart';
import '../../domain/models/puzzle_model.dart';
import '../widgets/achievement_toast.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int timeSeconds;
  final int stepsCount;
  final int hintsUsed;
  final int stars;
  final String difficulty;
  final int target;
  final List<CalcStep> solutionSteps;

  const ResultScreen({
    super.key,
    required this.timeSeconds,
    required this.stepsCount,
    required this.hintsUsed,
    required this.stars,
    required this.difficulty,
    required this.target,
    this.solutionSteps = const [],
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Staggered star animations
  late AnimationController _starController;
  late List<Animation<double>> _starScales;

  // Counter animation
  late AnimationController _counterController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    // Staggered star animation (3 stars, each delayed)
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _starScales = List.generate(3, (index) {
      final start = 0.1 + index * 0.25; // 0.1, 0.35, 0.6
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _starController,
          curve: Interval(start, end, curve: Curves.elasticOut),
        ),
      );
    });

    // Counter animation (numbers count up)
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animController.forward();
    _starController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _counterController.forward();
    });
    _confettiController.play();

    // Check for new achievements
    _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    final newly = await AchievementService.instance.checkAfterSolve(
      timeSeconds: widget.timeSeconds,
      steps: widget.stepsCount,
      hints: widget.hintsUsed,
      stars: widget.stars,
    );
    if (!mounted) return;
    for (int i = 0; i < newly.length; i++) {
      Future.delayed(Duration(milliseconds: 1500 + i * 800), () {
        if (mounted) showAchievementToast(context, newly[i]);
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    _starController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStars = widget.stars > 0 ? widget.stars : 1;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Spacer(),

                    // Stars (staggered bounce-in)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStars(effectiveStars),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'PUZZLE SOLVED!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${widget.target}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats cards
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStatsRow(),
                    ),

                    const Spacer(),

                    // Action buttons
                    _buildNextButton(context),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            color: AppTheme.primaryColor,
                            onTap: _shareResult,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.replay_rounded,
                            label: 'Replay',
                            onTap: () {
                              context.pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            onTap: () => context.go('/'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.2,
              colors: const [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.accentColor,
                AppTheme.successColor,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isFilled = index < count;
        final size = index == 1 ? 56.0 : 44.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedBuilder(
            animation: _starScales[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _starScales[index].value,
                child: child,
              );
            },
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: isFilled
                  ? const Color(0xFFFFD700)
                  : AppTheme.textMuted.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_outlined,
            label: 'Time',
            value: _formatTime(widget.timeSeconds),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.format_list_numbered_rounded,
            label: 'Steps',
            value: '${widget.stepsCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Hints',
            value: '${widget.hintsUsed}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: AppTheme.glassDecoration(borderRadius: 16),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _counterController,
            builder: (context, _) {
              // Parse the value and animate it
              final targetVal = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
              if (targetVal != null && targetVal > 0) {
                final current = (_counterController.value * targetVal).round();
                // Reconstruct with format (for time mm:ss)
                if (value.contains(':')) {
                  final totalSec = (widget.timeSeconds * _counterController.value).round();
                  final m = totalSec ~/ 60;
                  final s = totalSec % 60;
                  return Text(
                    '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }
                return Text(
                  '$current',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }
              return Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Play another puzzle at the same difficulty
        context.go('/game/${widget.difficulty}');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: AppTheme.primaryGlowDecoration(borderRadius: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Color(0xFF0A0E1A), size: 26),
            SizedBox(width: 8),
            Text(
              'NEXT PUZZLE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0E1A),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    final starEmoji = '⭐' * (widget.stars > 0 ? widget.stars : 1);
    final buffer = StringBuffer();
    buffer.writeln('🧮 CountiQ — Target: ${widget.target} $starEmoji');
    buffer.writeln();
    if (widget.solutionSteps.isNotEmpty) {
      for (int i = 0; i < widget.solutionSteps.length; i++) {
        final step = widget.solutionSteps[i];
        final circled = String.fromCharCode(0x2460 + i); // ①②③...
        final check = step.result == widget.target ? ' ✓' : '';
        buffer.writeln('$circled ${step.num1} ${step.operator} ${step.num2} = ${step.result}$check');
      }
      buffer.writeln();
    }
    buffer.write('⏱ ${_formatTime(widget.timeSeconds)} | ${widget.stepsCount} steps');
    if (widget.hintsUsed == 0) {
      buffer.write(' | No hints!');
    } else {
      buffer.write(' | ${widget.hintsUsed} hint${widget.hintsUsed > 1 ? 's' : ''}');
    }
    buffer.writeln();
    buffer.write('\nCan you solve it? #CountiQ #MathPuzzle');

    SharePlus.instance.share(
      ShareParams(text: buffer.toString()),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: AppTheme.glassDecoration(borderRadius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color ?? AppTheme.primaryColor, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
