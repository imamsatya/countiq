import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int timeSeconds;
  final int stepsCount;
  final int hintsUsed;
  final int stars;
  final String difficulty;
  final int target;

  const ResultScreen({
    super.key,
    required this.timeSeconds,
    required this.stepsCount,
    required this.hintsUsed,
    required this.stars,
    required this.difficulty,
    required this.target,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
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

                    // Stars
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildStars(effectiveStars),
                      ),
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
                            icon: Icons.replay_rounded,
                            label: 'Replay',
                            onTap: () {
                              context.pop(); // Go back to game (it will keep same puzzle)
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
        final size = index == 1 ? 56.0 : 44.0; // Middle star is bigger

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: isFilled
                ? const Color(0xFFFFD700)
                : AppTheme.textMuted.withValues(alpha: 0.3),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
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

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: AppTheme.glassDecoration(borderRadius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
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
