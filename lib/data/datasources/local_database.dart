import 'package:hive_flutter/hive_flutter.dart';

/// Local database for persisting game data using Hive.
class LocalDatabase {
  LocalDatabase._();
  static final instance = LocalDatabase._();

  late Box _settingsBox;
  late Box _statsBox;
  late Box _levelsBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Box get settingsBox => _settingsBox;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox('settings');
    _statsBox = await Hive.openBox('stats');
    _levelsBox = await Hive.openBox('levels');
    _initialized = true;
  }

  // ─── Settings ───────────────────────────────────────────────

  bool getSoundEnabled() =>
      _settingsBox.get('sound_enabled', defaultValue: true);

  Future<void> setSoundEnabled(bool value) =>
      _settingsBox.put('sound_enabled', value);

  bool getHapticEnabled() =>
      _settingsBox.get('haptic_enabled', defaultValue: true);

  Future<void> setHapticEnabled(bool value) =>
      _settingsBox.put('haptic_enabled', value);

  String getDifficulty() =>
      _settingsBox.get('difficulty', defaultValue: 'easy');

  Future<void> setDifficulty(String value) =>
      _settingsBox.put('difficulty', value);

  // ─── Level Progress ─────────────────────────────────────────

  /// Save completion data for a campaign level
  Future<void> saveLevelCompletion({
    required int levelNumber,
    required int stars,
    required int timeSeconds,
    required int steps,
    required int hints,
  }) async {
    final existing = _levelsBox.get('level_$levelNumber');
    final existingStars = existing?['stars'] ?? 0;
    final existingTime = existing?['time'] ?? 999999;

    // Only update if better stars, or same stars with better time
    if (stars > existingStars ||
        (stars == existingStars && timeSeconds < existingTime)) {
      await _levelsBox.put('level_$levelNumber', {
        'stars': stars,
        'time': timeSeconds,
        'steps': steps,
        'hints': hints,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }

    // Update stats
    await _incrementStat('total_puzzles_solved');
    await _addToStat('total_time_played', timeSeconds);
  }

  /// Get level data
  Map<String, dynamic>? getLevelData(int levelNumber) {
    final data = _levelsBox.get('level_$levelNumber');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get stars for a specific level (0 if not completed)
  int getLevelStars(int levelNumber) {
    return getLevelData(levelNumber)?['stars'] ?? 0;
  }

  /// Get the highest completed level number
  int getHighestCompletedLevel() {
    int highest = 0;
    for (final key in _levelsBox.keys) {
      if (key is String && key.startsWith('level_')) {
        final num = int.tryParse(key.substring(6));
        if (num != null && num > highest) {
          highest = num;
        }
      }
    }
    return highest;
  }

  /// Get total completed levels count
  int getCompletedLevelsCount() {
    int count = 0;
    for (final key in _levelsBox.keys) {
      if (key is String && key.startsWith('level_')) {
        count++;
      }
    }
    return count;
  }

  /// Get total stars earned
  int getTotalStars() {
    int total = 0;
    for (final key in _levelsBox.keys) {
      if (key is String && key.startsWith('level_')) {
        final data = _levelsBox.get(key);
        total += (data?['stars'] ?? 0) as int;
      }
    }
    return total;
  }

  // ─── Statistics ──────────────────────────────────────────────

  int getStat(String key) => _statsBox.get(key, defaultValue: 0);

  Future<void> _incrementStat(String key) async {
    final current = getStat(key);
    await _statsBox.put(key, current + 1);
  }

  Future<void> _addToStat(String key, int value) async {
    final current = getStat(key);
    await _statsBox.put(key, current + value);
  }

  int get totalPuzzlesSolved => getStat('total_puzzles_solved');
  int get totalTimePlayed => getStat('total_time_played');
  int get totalHintsUsed => getStat('total_hints_used');

  /// Get best time across all puzzles
  int get bestTime {
    int best = 999999;
    for (final key in _levelsBox.keys) {
      if (key is String && key.startsWith('level_')) {
        final data = _levelsBox.get(key);
        final time = data?['time'] ?? 999999;
        if (time < best) best = time;
      }
    }
    return best == 999999 ? 0 : best;
  }

  /// Record a quick play completion (non-campaign)
  Future<void> recordQuickPlay({
    required int timeSeconds,
    required int steps,
    required int hints,
    required String difficulty,
  }) async {
    await _incrementStat('total_puzzles_solved');
    await _incrementStat('quick_play_${difficulty}_solved');
    await _addToStat('total_time_played', timeSeconds);
    if (hints > 0) {
      await _addToStat('total_hints_used', hints);
    }
  }

  // ─── Time Attack Stats ──────────────────────────────────────

  int get timeAttackBest => _settingsBox.get('time_attack_best', defaultValue: 0);
  int get timeAttackTotalGames => _settingsBox.get('time_attack_total_games', defaultValue: 0);
  int get timeAttackTotalSolved => _settingsBox.get('time_attack_total_solved', defaultValue: 0);

  // ─── Locale ─────────────────────────────────────────────────

  String getLocale() => _settingsBox.get('locale', defaultValue: 'system');

  Future<void> setLocale(String locale) => _settingsBox.put('locale', locale);

  // ─── Onboarding ─────────────────────────────────────────────

  /// Returns true if the user has never completed onboarding
  bool get isFirstLaunch =>
      !_settingsBox.get('onboarding_done', defaultValue: false);

  /// Mark onboarding as completed so it won't show again
  Future<void> markOnboardingDone() =>
      _settingsBox.put('onboarding_done', true);

  // ─── Reset ──────────────────────────────────────────────────

  /// Reset ALL progress: settings, stats, levels, daily data.
  Future<void> resetAll() async {
    await _settingsBox.clear();
    await _statsBox.clear();
    await _levelsBox.clear();
  }
}
