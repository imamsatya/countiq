import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/engine/campaign_generator.dart';
import '../../data/datasources/local_database.dart';
import '../providers/locale_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final db = LocalDatabase.instance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Overview
                    _buildSectionTitle(AppStrings.get('overview')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.emoji_events_rounded,
                            value: '${db.totalPuzzlesSolved}',
                            label: AppStrings.get('puzzles_solved'),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star_rounded,
                            value: '${db.getTotalStars()}',
                            label: AppStrings.get('stars_earned'),
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timer_rounded,
                            value: _formatTimeLong(db.totalTimePlayed),
                            label: AppStrings.get('total_time'),
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.speed_rounded,
                            value: _formatTime(db.bestTime),
                            label: AppStrings.get('best_time'),
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Campaign Progress
                    _buildSectionTitle(AppStrings.get('campaign_progress')),
                    const SizedBox(height: 10),
                    _buildProgressCard(db),

                    const SizedBox(height: 24),

                    // Quick Play
                    _buildSectionTitle(AppStrings.get('quick_play')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDiffStatCard(
                            emoji: '🟢',
                            label: AppStrings.get('easy'),
                            value: db.getStat('quick_play_easy_solved'),
                            color: AppTheme.easyColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDiffStatCard(
                            emoji: '🟡',
                            label: AppStrings.get('medium'),
                            value: db.getStat('quick_play_medium_solved'),
                            color: AppTheme.mediumColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDiffStatCard(
                            emoji: '🔴',
                            label: AppStrings.get('hard'),
                            value: db.getStat('quick_play_hard_solved'),
                            color: AppTheme.hardColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Hints
                    _buildSectionTitle(AppStrings.get('hints')),
                    const SizedBox(height: 10),
                    _buildStatCard(
                      icon: Icons.lightbulb_outline_rounded,
                      value: '${db.totalHintsUsed}',
                      label: AppStrings.get('total_hints_used'),
                      color: AppTheme.warningColor,
                      wide: true,
                    ),

                    const SizedBox(height: 24),

                    // Time Attack
                    _buildSectionTitle(AppStrings.get('time_attack')),
                    const SizedBox(height: 10),
                    if (db.timeAttackTotalGames > 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.bolt_rounded,
                              value: '${db.timeAttackBest}',
                              label: AppStrings.get('best_score'),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.sports_esports_rounded,
                              value: '${db.timeAttackTotalGames}',
                              label: AppStrings.get('games_played'),
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_outline_rounded,
                              value: '${db.timeAttackTotalSolved}',
                              label: AppStrings.get('total_solved'),
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.trending_up_rounded,
                              value: db.timeAttackTotalGames > 0
                                  ? (db.timeAttackTotalSolved / db.timeAttackTotalGames).toStringAsFixed(1)
                                  : '0',
                              label: AppStrings.get('avg_per_game'),
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: AppTheme.glassDecoration(borderRadius: 16),
                        child: Column(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.get('time_attack_empty'),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Text(
              AppStrings.get('statistics').toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool wide = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: AppTheme.glassDecoration(borderRadius: 16),
      child: wide
          ? Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildDiffStatCard({
    required String emoji,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: AppTheme.glassDecoration(borderRadius: 14),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(LocalDatabase db) {
    final completed = db.getCompletedLevelsCount();
    final total = CampaignGenerator.totalLevels;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed / $total Levels',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceLight,
              color: AppTheme.primaryColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatTimeLong(int totalSeconds) {
    if (totalSeconds == 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
