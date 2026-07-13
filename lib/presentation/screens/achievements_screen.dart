import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/achievement_service.dart';
import '../../core/l10n/app_strings.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AchievementService.instance;
    final unlocked = service.unlockedCount;
    final total = AchievementService.allAchievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    // Group by category
    final grouped = <AchievementCategory, List<Achievement>>{};
    for (final a in AchievementService.allAchievements) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, unlocked, total, progress),
              const SizedBox(height: 8),

              // Achievement list
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    for (final category in AchievementCategory.values) ...[
                      if (grouped.containsKey(category)) ...[
                        _buildCategoryHeader(category),
                        const SizedBox(height: 8),
                        ...grouped[category]!.map(
                          (a) => _buildAchievementTile(a, service.isUnlocked(a.id)),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, int unlocked, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.glassDecoration(borderRadius: 12),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.get('achievements'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: AppTheme.glassDecoration(borderRadius: 12),
                child: Text(
                  '$unlocked/$total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppTheme.surfaceLight,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(AchievementCategory category) {
    final labels = {
      AchievementCategory.beginner: ('🌱', AppStrings.get('beginner')),
      AchievementCategory.campaign: ('📖', AppStrings.get('campaign')),
      AchievementCategory.quickPlay: ('🎮', AppStrings.get('quick_play')),
      AchievementCategory.daily: ('📅', AppStrings.get('daily_challenge')),
      AchievementCategory.mastery: ('👑', AppStrings.get('mastery')),
    };
    final (icon, label) = labels[category] ?? ('🏆', AppStrings.get('other'));

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement, bool unlocked) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: unlocked
            ? AppTheme.primaryColor.withValues(alpha: 0.08)
            : AppTheme.surfaceColor.withValues(alpha: 0.5),
        border: Border.all(
          color: unlocked
              ? AppTheme.primaryColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: unlocked
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceLight.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Text(
                unlocked ? achievement.icon : '🔒',
                style: TextStyle(
                  fontSize: unlocked ? 22 : 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Title & description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: unlocked
                        ? Colors.white
                        : AppTheme.textMuted.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: unlocked
                        ? AppTheme.textSecondary.withValues(alpha: 0.8)
                        : AppTheme.textMuted.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          // Check
          if (unlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.successColor, size: 22),
        ],
      ),
    );
  }
}
