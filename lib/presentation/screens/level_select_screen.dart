import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  static const int totalLevels = 100;
  static const int levelsPerPage = 25;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase.instance;
    final totalCompleted = db.getCompletedLevelsCount();
    final totalStars = db.getTotalStars();
    final maxPages = (totalLevels / levelsPerPage).ceil();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, totalCompleted, totalStars),
              const SizedBox(height: 8),

              // Page indicator
              _buildPageIndicator(maxPages),
              const SizedBox(height: 12),

              // Level grid
              Expanded(
                child: _buildLevelGrid(db),
              ),

              // Page navigation
              _buildPageNav(maxPages),
              const SizedBox(height: 16),
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
            child: const Text(
              'SELECT LEVEL',
              style: TextStyle(
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

  Widget _buildPageIndicator(int maxPages) {
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

  Widget _buildLevelGrid(LocalDatabase db) {
    final startLevel = _currentPage * levelsPerPage + 1;
    final endLevel = (startLevel + levelsPerPage - 1).clamp(1, totalLevels);
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
                    'Prev',
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
            'Page ${_currentPage + 1} of $maxPages',
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
                    'Next',
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
