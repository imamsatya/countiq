import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/datasources/local_database.dart';
import '../../core/services/daily_challenge_service.dart';
import '../widgets/particle_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _dailyPulseController;

  // Staggered animations
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;
  late Animation<double> _bottomFade;
  late Animation<double> _dailyGlow;

  @override
  void initState() {
    super.initState();

    // Main entry animation (1200ms total with stagger)
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Daily card pulse glow (looping)
    _dailyPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _dailyGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dailyPulseController, curve: Curves.easeInOut),
    );

    final isCompleted = DailyChallengeService.instance.isTodayCompleted;
    if (!isCompleted) {
      _dailyPulseController.repeat(reverse: true);
    }

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _dailyPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase.instance;
    final highestLevel = db.getHighestCompletedLevel();
    final totalStars = db.getTotalStars();
    final totalSolved = db.totalPuzzlesSolved;

    return Scaffold(
      body: ParticleBackground(
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Spacer(flex: 2),

                  // Logo (bounce in)
                  ScaleTransition(
                    scale: _logoScale,
                    child: _buildLogo(),
                  ),
                  const SizedBox(height: 12),

                  // Title (fade + slide)
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: const Text(
                              'CountiQ',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.appSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary.withValues(alpha: 0.7),
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mini stats row
                  FadeTransition(
                    opacity: _titleFade,
                    child: totalSolved > 0
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMiniStat(Icons.emoji_events_rounded,
                                    '$totalSolved', AppTheme.primaryColor),
                                const SizedBox(width: 20),
                                _buildMiniStat(Icons.star_rounded,
                                    '$totalStars', const Color(0xFFFFD700)),
                                if (highestLevel > 0) ...[
                                  const SizedBox(width: 20),
                                  _buildMiniStat(Icons.flag_rounded,
                                      'Lv.$highestLevel', AppTheme.successColor),
                                ],
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Buttons section (fade + slide)
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: SlideTransition(
                      position: _buttonsSlide,
                      child: Column(
                        children: [
                          // Daily Challenge card
                          _buildDailyCard(context),
                          const SizedBox(height: 12),

                          // Campaign button
                          _buildCampaignButton(context, highestLevel),
                          const SizedBox(height: 10),

                          // Quick Play difficulty selectors
                          Row(
                            children: [
                              Expanded(
                                child: _buildDifficultyButton(
                                  context,
                                  label: '🟢 ${AppStrings.get('easy')}',
                                  difficulty: 'easy',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDifficultyButton(
                                  context,
                                  label: '🟡 ${AppStrings.get('medium')}',
                                  difficulty: 'medium',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDifficultyButton(
                                  context,
                                  label: '🔴 ${AppStrings.get('hard')}',
                                  difficulty: 'hard',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Time Attack + Level Select row
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeAttackButton(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMenuButton(
                                  context,
                                  icon: Icons.grid_view_rounded,
                                  label: AppStrings.get('select_level'),
                                  onTap: () => context.push('/levels'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom icon row (fade in last)
                  FadeTransition(
                    opacity: _bottomFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          icon: Icons.bar_chart_rounded,
                          tooltip: 'Statistics',
                          onTap: () => context.push('/statistics'),
                        ),
                        const SizedBox(width: 16),
                        _buildIconButton(
                          icon: Icons.emoji_events_rounded,
                          tooltip: 'Achievements',
                          onTap: () => context.push('/achievements'),
                        ),
                        const SizedBox(width: 16),
                        _buildIconButton(
                          icon: Icons.help_outline_rounded,
                          tooltip: 'How to Play',
                          onTap: () => context.push('/how-to-play'),
                        ),
                        const SizedBox(width: 16),
                        _buildIconButton(
                          icon: Icons.settings_rounded,
                          tooltip: 'Settings',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Footer
                  FadeTransition(
                    opacity: _bottomFade,
                    child: Text(
                      AppStrings.get('app_footer'),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyCard(BuildContext context) {
    final daily = DailyChallengeService.instance;
    final isCompleted = daily.isTodayCompleted;
    final streak = daily.streak;
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return GestureDetector(
      onTap: () => context.push('/daily'),
      child: AnimatedBuilder(
        animation: _dailyGlow,
        builder: (context, child) {
          final glowIntensity = isCompleted ? 0.0 : _dailyGlow.value * 0.15;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isCompleted
                    ? [
                        AppTheme.successColor.withValues(alpha: 0.15),
                        AppTheme.successColor.withValues(alpha: 0.05),
                      ]
                    : [
                        AppTheme.primaryColor.withValues(alpha: 0.15 + glowIntensity),
                        AppTheme.primaryColor.withValues(alpha: 0.05 + glowIntensity * 0.5),
                      ],
              ),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.successColor.withValues(alpha: 0.3)
                    : AppTheme.primaryColor.withValues(alpha: 0.3 + glowIntensity),
              ),
              boxShadow: isCompleted
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: glowIntensity * 0.5),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                    ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.today_rounded,
              color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCompleted ? AppStrings.dailyComplete : AppStrings.dailyChallenge,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppTheme.successColor : Colors.white,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withValues(alpha: 0.15),
                ),
                child: Text(
                  '🔥 $streak',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '#',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0E1A),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignButton(BuildContext context, int highestLevel) {
    final nextLevel = highestLevel + 1;
    final isResume = highestLevel > 0;

    return GestureDetector(
      onTap: () => context.push('/campaign/$nextLevel'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: AppTheme.primaryGlowDecoration(borderRadius: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isResume ? Icons.play_arrow_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF0A0E1A),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isResume ? 'CONTINUE Level $nextLevel' : AppStrings.play,
              style: const TextStyle(
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

  Widget _buildDifficultyButton(
    BuildContext context, {
    required String label,
    required String difficulty,
  }) {
    return GestureDetector(
      onTap: () => context.push('/game/$difficulty'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: AppTheme.glassDecoration(borderRadius: 14),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeAttackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/time-attack'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.orange.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⚡', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            Text(
              'Time Attack',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: AppTheme.glassDecoration(borderRadius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18),
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

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: AppTheme.glassDecoration(borderRadius: 16),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
      ),
    );
  }
}
