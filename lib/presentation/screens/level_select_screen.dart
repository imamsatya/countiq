import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/engine/campaign_generator.dart';
import '../../data/datasources/local_database.dart';
import '../providers/locale_provider.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  static const int levelsPerPage = 25;
  int _selectedTierIndex = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Auto-select the tier the player is currently on
    final highestCompleted = LocalDatabase.instance.getHighestCompletedLevel();
    final nextLevel = highestCompleted + 1;
    for (int i = 0; i < CampaignGenerator.tiers.length; i++) {
      final tier = CampaignGenerator.tiers[i];
      if (nextLevel >= tier.startLevel && nextLevel <= tier.endLevel) {
        _selectedTierIndex = i;
        // Set page to the one containing the next level
        final levelInTier = nextLevel - tier.startLevel;
        _currentPage = levelInTier ~/ levelsPerPage;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final db = LocalDatabase.instance;
    final totalCompleted = db.getCompletedLevelsCount();
    final totalStars = db.getTotalStars();
    final tier = CampaignGenerator.tiers[_selectedTierIndex];
    final maxPages = (tier.levelCount / levelsPerPage).ceil();

    // Clamp current page
    if (_currentPage >= maxPages) _currentPage = maxPages - 1;
    if (_currentPage < 0) _currentPage = 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, totalCompleted, totalStars),
              const SizedBox(height: 8),

              // Tier selector (horizontal scrollable chips)
              _buildTierSelector(db),
              const SizedBox(height: 8),

              // Page indicator
              if (maxPages > 1) ...[
                _buildPageIndicator(maxPages),
                const SizedBox(height: 8),
              ],

              // Level grid
              Expanded(
                child: _buildLevelGrid(db, tier),
              ),

              // Page navigation
              if (maxPages > 1) _buildPageNav(maxPages),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completed, int totalStars) {
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
              AppStrings.get('select_level').toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          // Stats summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$totalStars',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelector(LocalDatabase db) {
    final highestCompleted = db.getHighestCompletedLevel();

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: CampaignGenerator.tiers.length,
        itemBuilder: (context, index) {
          final tier = CampaignGenerator.tiers[index];
          final isSelected = index == _selectedTierIndex;
          // A tier is unlocked if the player has reached at least the first level of that tier
          final isTierUnlocked = highestCompleted >= tier.startLevel - 1;
          // Count completed levels in this tier
          int tierCompleted = 0;
          for (int lv = tier.startLevel; lv <= tier.endLevel; lv++) {
            if (db.getLevelStars(lv) > 0) tierCompleted++;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: isTierUnlocked
                  ? () => setState(() {
                        _selectedTierIndex = index;
                        _currentPage = 0;
                      })
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : isTierUnlocked
                          ? AppTheme.surfaceColor.withValues(alpha: 0.5)
                          : AppTheme.surfaceColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.6)
                        : isTierUnlocked
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.03),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tier.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: !isTierUnlocked
                            ? AppTheme.textMuted.withValues(alpha: 0.3)
                            : isSelected
                                ? AppTheme.primaryColor
                                : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (isTierUnlocked && tierCompleted > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$tierCompleted/${tier.levelCount}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    if (!isTierUnlocked) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock_rounded,
                          color: AppTheme.textMuted.withValues(alpha: 0.3),
                          size: 12),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int maxPages) {
    // For many pages, show a compact indicator
    if (maxPages > 10) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '${AppStrings.get('page')} ${_currentPage + 1} ${AppStrings.get('of')} $maxPages',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxPages, (index) {
        final isActive = index == _currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Widget _buildLevelGrid(LocalDatabase db, CampaignTier tier) {
    final startLevel = tier.startLevel + _currentPage * levelsPerPage;
    final endLevel = (startLevel + levelsPerPage - 1).clamp(tier.startLevel, tier.endLevel);
    final highestCompleted = db.getHighestCompletedLevel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: endLevel - startLevel + 1,
        itemBuilder: (context, index) {
          final levelNum = startLevel + index;
          final stars = db.getLevelStars(levelNum);
          final isCompleted = stars > 0;
          final isUnlocked = levelNum <= highestCompleted + 1;
          final isCurrent = levelNum == highestCompleted + 1;

          return GestureDetector(
            onTap: isUnlocked
                ? () {
                    context.push('/campaign/$levelNum');
                    HapticFeedback.lightImpact();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: !isUnlocked
                    ? AppTheme.surfaceColor.withValues(alpha: 0.3)
                    : isCurrent
                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                        : isCompleted
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.surfaceColor.withValues(alpha: 0.6),
                border: Border.all(
                  color: !isUnlocked
                      ? Colors.white.withValues(alpha: 0.03)
                      : isCurrent
                          ? AppTheme.primaryColor.withValues(alpha: 0.5)
                          : isCompleted
                              ? AppTheme.successColor.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.08),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isUnlocked)
                    Icon(Icons.lock_rounded,
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                        size: 18)
                  else
                    Text(
                      '$levelNum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : isCompleted
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  if (isCompleted) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 10,
                          color: i < stars
                              ? const Color(0xFFFFD700)
                              : AppTheme.textMuted.withValues(alpha: 0.3),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageNav(int maxPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left_rounded,
                      color: _currentPage > 0
                          ? Colors.white
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                      size: 20),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.get('prev'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _currentPage > 0
                          ? Colors.white
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '${AppStrings.get('page')} ${_currentPage + 1} ${AppStrings.get('of')} $maxPages',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          GestureDetector(
            onTap: _currentPage < maxPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.get('next'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _currentPage < maxPages - 1
                          ? Colors.white
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: _currentPage < maxPages - 1
                          ? Colors.white
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                      size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
