import '../../data/datasources/local_database.dart';
import '../l10n/achievement_strings.dart';

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}

enum AchievementCategory { beginner, campaign, quickPlay, daily, mastery }

/// Manages achievement tracking and unlocking
class AchievementService {
  AchievementService._();
  static final instance = AchievementService._();

  static List<Achievement> get allAchievements => [
    // Beginner
    Achievement(
      id: 'first_solve',
      title: AchievementStrings.get('ach_title_first_solve'),
      description: AchievementStrings.get('ach_desc_first_solve'),
      icon: '🎯',
      category: AchievementCategory.beginner,
    ),
    Achievement(
      id: 'no_hint_solve',
      title: AchievementStrings.get('ach_title_no_hint_solve'),
      description: AchievementStrings.get('ach_desc_no_hint_solve'),
      icon: '🧠',
      category: AchievementCategory.beginner,
    ),
    Achievement(
      id: 'speed_demon_30',
      title: AchievementStrings.get('ach_title_speed_demon_30'),
      description: AchievementStrings.get('ach_desc_speed_demon_30'),
      icon: '⚡',
      category: AchievementCategory.beginner,
    ),
    Achievement(
      id: 'three_stars',
      title: AchievementStrings.get('ach_title_three_stars'),
      description: AchievementStrings.get('ach_desc_three_stars'),
      icon: '⭐',
      category: AchievementCategory.beginner,
    ),

    // Campaign
    Achievement(
      id: 'campaign_10',
      title: AchievementStrings.get('ach_title_campaign_10'),
      description: AchievementStrings.get('ach_desc_campaign_10'),
      icon: '📖',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_25',
      title: AchievementStrings.get('ach_title_campaign_25'),
      description: AchievementStrings.get('ach_desc_campaign_25'),
      icon: '🏅',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_50',
      title: AchievementStrings.get('ach_title_campaign_50'),
      description: AchievementStrings.get('ach_desc_campaign_50'),
      icon: '🏆',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_100',
      title: AchievementStrings.get('ach_title_campaign_100'),
      description: AchievementStrings.get('ach_desc_campaign_100'),
      icon: '👑',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_200',
      title: AchievementStrings.get('ach_title_campaign_200'),
      description: AchievementStrings.get('ach_desc_campaign_200'),
      icon: '⚔️',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_500',
      title: AchievementStrings.get('ach_title_campaign_500'),
      description: AchievementStrings.get('ach_desc_campaign_500'),
      icon: '🔥',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_800',
      title: AchievementStrings.get('ach_title_campaign_800'),
      description: AchievementStrings.get('ach_desc_campaign_800'),
      icon: '🌟',
      category: AchievementCategory.campaign,
    ),
    Achievement(
      id: 'campaign_1200',
      title: AchievementStrings.get('ach_title_campaign_1200'),
      description: AchievementStrings.get('ach_desc_campaign_1200'),
      icon: '💎',
      category: AchievementCategory.campaign,
    ),

    // Quick Play
    Achievement(
      id: 'quick_10',
      title: AchievementStrings.get('ach_title_quick_10'),
      description: AchievementStrings.get('ach_desc_quick_10'),
      icon: '💚',
      category: AchievementCategory.quickPlay,
    ),
    Achievement(
      id: 'quick_50',
      title: AchievementStrings.get('ach_title_quick_50'),
      description: AchievementStrings.get('ach_desc_quick_50'),
      icon: '💜',
      category: AchievementCategory.quickPlay,
    ),
    Achievement(
      id: 'all_difficulties',
      title: AchievementStrings.get('ach_title_all_difficulties'),
      description: AchievementStrings.get('ach_desc_all_difficulties'),
      icon: '🎨',
      category: AchievementCategory.quickPlay,
    ),
    Achievement(
      id: 'hard_solver',
      title: AchievementStrings.get('ach_title_hard_solver'),
      description: AchievementStrings.get('ach_desc_hard_solver'),
      icon: '🔴',
      category: AchievementCategory.quickPlay,
    ),

    // Daily
    Achievement(
      id: 'daily_first',
      title: AchievementStrings.get('ach_title_daily_first'),
      description: AchievementStrings.get('ach_desc_daily_first'),
      icon: '📅',
      category: AchievementCategory.daily,
    ),
    Achievement(
      id: 'streak_3',
      title: AchievementStrings.get('ach_title_streak_3'),
      description: AchievementStrings.get('ach_desc_streak_3'),
      icon: '🔥',
      category: AchievementCategory.daily,
    ),
    Achievement(
      id: 'streak_7',
      title: AchievementStrings.get('ach_title_streak_7'),
      description: AchievementStrings.get('ach_desc_streak_7'),
      icon: '💪',
      category: AchievementCategory.daily,
    ),
    Achievement(
      id: 'streak_30',
      title: AchievementStrings.get('ach_title_streak_30'),
      description: AchievementStrings.get('ach_desc_streak_30'),
      icon: '🌟',
      category: AchievementCategory.daily,
    ),

    // Mastery
    Achievement(
      id: 'speed_15',
      title: AchievementStrings.get('ach_title_speed_15'),
      description: AchievementStrings.get('ach_desc_speed_15'),
      icon: '🌩️',
      category: AchievementCategory.mastery,
    ),
    Achievement(
      id: 'total_100',
      title: AchievementStrings.get('ach_title_total_100'),
      description: AchievementStrings.get('ach_desc_total_100'),
      icon: '💯',
      category: AchievementCategory.mastery,
    ),
    Achievement(
      id: 'stars_100',
      title: AchievementStrings.get('ach_title_stars_100'),
      description: AchievementStrings.get('ach_desc_stars_100'),
      icon: '✨',
      category: AchievementCategory.mastery,
    ),
    Achievement(
      id: 'two_step_solve',
      title: AchievementStrings.get('ach_title_two_step_solve'),
      description: AchievementStrings.get('ach_desc_two_step_solve'),
      icon: '🎯',
      category: AchievementCategory.mastery,
    ),
  ];

  /// Check if an achievement is unlocked
  bool isUnlocked(String id) {
    final db = LocalDatabase.instance;
    return db.settingsBox.get('ach_$id', defaultValue: false) == true;
  }

  /// Unlock an achievement
  Future<bool> unlock(String id) async {
    if (isUnlocked(id)) return false;
    await LocalDatabase.instance.settingsBox.put('ach_$id', true);
    await LocalDatabase.instance.settingsBox.put(
      'ach_${id}_at',
      DateTime.now().toIso8601String(),
    );
    return true; // newly unlocked
  }

  /// Get count of unlocked achievements
  int get unlockedCount {
    int count = 0;
    for (final a in allAchievements) {
      if (isUnlocked(a.id)) count++;
    }
    return count;
  }

  /// Check and unlock achievements based on current stats.
  /// Returns list of newly unlocked achievements.
  Future<List<Achievement>> checkAndUnlock() async {
    final db = LocalDatabase.instance;
    final newly = <Achievement>[];

    final totalSolved = db.totalPuzzlesSolved;
    final totalStars = db.getTotalStars();
    final completedLevels = db.getCompletedLevelsCount();
    final easyCount = db.getStat('quick_play_easy_solved');
    final mediumCount = db.getStat('quick_play_medium_solved');
    final hardCount = db.getStat('quick_play_hard_solved');

    // Import daily service lazily
    final dailyStreak = db.getStat('daily_best_streak');

    // Beginner
    if (totalSolved >= 1 && await unlock('first_solve')) {
      newly.add(_find('first_solve'));
    }
    if (await _checkNoHintSolve(db)) {
      if (await unlock('no_hint_solve')) newly.add(_find('no_hint_solve'));
    }

    // Campaign
    if (completedLevels >= 10 && await unlock('campaign_10')) {
      newly.add(_find('campaign_10'));
    }
    if (completedLevels >= 25 && await unlock('campaign_25')) {
      newly.add(_find('campaign_25'));
    }
    if (completedLevels >= 50 && await unlock('campaign_50')) {
      newly.add(_find('campaign_50'));
    }
    if (completedLevels >= 100 && await unlock('campaign_100')) {
      newly.add(_find('campaign_100'));
    }
    if (completedLevels >= 200 && await unlock('campaign_200')) {
      newly.add(_find('campaign_200'));
    }
    if (completedLevels >= 500 && await unlock('campaign_500')) {
      newly.add(_find('campaign_500'));
    }
    if (completedLevels >= 800 && await unlock('campaign_800')) {
      newly.add(_find('campaign_800'));
    }
    if (completedLevels >= 1200 && await unlock('campaign_1200')) {
      newly.add(_find('campaign_1200'));
    }

    // Quick Play
    final totalQuick = easyCount + mediumCount + hardCount;
    if (totalQuick >= 10 && await unlock('quick_10')) {
      newly.add(_find('quick_10'));
    }
    if (totalQuick >= 50 && await unlock('quick_50')) {
      newly.add(_find('quick_50'));
    }
    if (easyCount > 0 && mediumCount > 0 && hardCount > 0) {
      if (await unlock('all_difficulties')) newly.add(_find('all_difficulties'));
    }
    if (hardCount >= 10 && await unlock('hard_solver')) {
      newly.add(_find('hard_solver'));
    }

    // Daily
    if (dailyStreak >= 1 && await unlock('daily_first')) {
      newly.add(_find('daily_first'));
    }
    if (dailyStreak >= 3 && await unlock('streak_3')) {
      newly.add(_find('streak_3'));
    }
    if (dailyStreak >= 7 && await unlock('streak_7')) {
      newly.add(_find('streak_7'));
    }
    if (dailyStreak >= 30 && await unlock('streak_30')) {
      newly.add(_find('streak_30'));
    }

    // Mastery
    if (totalSolved >= 100 && await unlock('total_100')) {
      newly.add(_find('total_100'));
    }
    if (totalStars >= 100 && await unlock('stars_100')) {
      newly.add(_find('stars_100'));
    }

    return newly;
  }

  /// Check time-based & step-based achievements after a solve
  Future<List<Achievement>> checkAfterSolve({
    required int timeSeconds,
    required int steps,
    required int hints,
    required int stars,
  }) async {
    final newly = <Achievement>[];

    if (timeSeconds <= 30 && await unlock('speed_demon_30')) {
      newly.add(_find('speed_demon_30'));
    }
    if (timeSeconds <= 15 && await unlock('speed_15')) {
      newly.add(_find('speed_15'));
    }
    if (stars == 3 && await unlock('three_stars')) {
      newly.add(_find('three_stars'));
    }
    if (hints == 0 && await unlock('no_hint_solve')) {
      newly.add(_find('no_hint_solve'));
    }
    if (steps <= 2 && await unlock('two_step_solve')) {
      newly.add(_find('two_step_solve'));
    }

    // Also check general milestones
    newly.addAll(await checkAndUnlock());

    return newly;
  }

  Achievement _find(String id) =>
      allAchievements.firstWhere((a) => a.id == id);

  Future<bool> _checkNoHintSolve(LocalDatabase db) async {
    // Check if any puzzle was solved without hints
    return db.totalPuzzlesSolved > 0 &&
        db.totalHintsUsed < db.totalPuzzlesSolved;
  }
}
