import '../../data/datasources/local_database.dart';

/// Lightweight localization for CountiQ (EN / ID).
/// Access via `AppStrings.get('key')` or the shorthand getters.
class AppStrings {
  AppStrings._();

  static String get _locale => LocalDatabase.instance.getLocale();

  static final Map<String, Map<String, String>> _strings = {
    // ─── General ──────────────────────────────────────────
    'app_name': {'en': 'CountiQ', 'id': 'CountiQ'},
    'app_subtitle': {'en': 'REACH THE NUMBER', 'id': 'RAIH ANGKANYA'},
    'app_footer': {'en': 'A number puzzle game', 'id': 'Game teka-teki angka'},

    // ─── Home Screen ──────────────────────────────────────
    'play': {'en': 'PLAY', 'id': 'MAIN'},
    'continue_level': {'en': 'CONTINUE Level', 'id': 'LANJUT Level'},
    'daily_challenge': {'en': 'Daily Challenge', 'id': 'Tantangan Harian'},
    'daily_complete': {'en': 'Daily Complete ✓', 'id': 'Harian Selesai ✓'},
    'easy': {'en': 'Easy', 'id': 'Mudah'},
    'medium': {'en': 'Medium', 'id': 'Sedang'},
    'hard': {'en': 'Hard', 'id': 'Sulit'},
    'time_attack': {'en': 'Time Attack', 'id': 'Serangan Waktu'},
    'select_level': {'en': 'Select Level', 'id': 'Pilih Level'},
    'statistics': {'en': 'Statistics', 'id': 'Statistik'},
    'achievements': {'en': 'Achievements', 'id': 'Pencapaian'},
    'how_to_play': {'en': 'How to Play', 'id': 'Cara Bermain'},
    'settings': {'en': 'Settings', 'id': 'Pengaturan'},

    // ─── Game Screen ──────────────────────────────────────
    'target': {'en': 'TARGET', 'id': 'TARGET'},
    'target_reached': {'en': '🎉 TARGET REACHED!', 'id': '🎉 TARGET TERCAPAI!'},
    'tap_to_start': {'en': 'Tap a number to start', 'id': 'Ketuk angka untuk mulai'},
    'hint': {'en': 'Hint', 'id': 'Petunjuk'},
    'skip': {'en': 'Skip', 'id': 'Lewati'},
    'result': {'en': 'Result', 'id': 'Hasil'},
    'solve_it': {'en': 'Solve it!', 'id': 'Selesaikan!'},
    'cannot_divide_zero': {'en': 'Cannot divide by zero', 'id': 'Tidak bisa dibagi nol'},
    'not_whole': {'en': 'is not a whole number', 'id': 'bukan bilangan bulat'},
    'would_be_negative': {'en': 'would be negative or zero', 'id': 'hasilnya negatif atau nol'},
    'invalid_operation': {'en': 'Invalid operation', 'id': 'Operasi tidak valid'},

    // ─── Result Screen ────────────────────────────────────
    'puzzle_solved': {'en': 'PUZZLE SOLVED!', 'id': 'TEKA-TEKI TERPECAHKAN!'},
    'next_puzzle': {'en': 'NEXT PUZZLE', 'id': 'SOAL BERIKUTNYA'},
    'share': {'en': 'Share', 'id': 'Bagikan'},
    'replay': {'en': 'Replay', 'id': 'Ulang'},
    'home': {'en': 'Home', 'id': 'Beranda'},
    'time': {'en': 'Time', 'id': 'Waktu'},
    'steps': {'en': 'Steps', 'id': 'Langkah'},
    'hints': {'en': 'Hints', 'id': 'Petunjuk'},

    // ─── Daily Challenge ──────────────────────────────────
    'come_back_tomorrow': {'en': 'Come back tomorrow!', 'id': 'Kembali besok!'},
    'streak': {'en': 'Streak', 'id': 'Beruntun'},
    'completed': {'en': 'Completed', 'id': 'Selesai'},

    // ─── Level Select ─────────────────────────────────────
    'level_select': {'en': 'LEVEL SELECT', 'id': 'PILIH LEVEL'},
    'locked': {'en': 'Locked', 'id': 'Terkunci'},

    // ─── Settings ─────────────────────────────────────────
    'sound_effects': {'en': 'Sound Effects', 'id': 'Efek Suara'},
    'haptic_feedback': {'en': 'Haptic Feedback', 'id': 'Getaran Haptic'},
    'language': {'en': 'Language', 'id': 'Bahasa'},
    'english': {'en': 'English', 'id': 'English'},
    'indonesian': {'en': 'Bahasa Indonesia', 'id': 'Bahasa Indonesia'},
    'game': {'en': 'Game', 'id': 'Permainan'},
    'about': {'en': 'About', 'id': 'Tentang'},
    'version': {'en': 'Version', 'id': 'Versi'},
    'rate_app': {'en': 'Rate This App', 'id': 'Beri Rating'},
    'share_friends': {'en': 'Share with Friends', 'id': 'Bagikan ke Teman'},
    'data': {'en': 'Data', 'id': 'Data'},
    'reset_progress': {'en': 'Reset All Progress', 'id': 'Reset Semua Progres'},
    'reset_confirm_title': {'en': 'Reset All Progress?', 'id': 'Reset Semua Progres?'},
    'reset_confirm_body': {
      'en': 'This will delete all your level progress, stars, and statistics. This action cannot be undone.',
      'id': 'Ini akan menghapus semua progres level, bintang, dan statistik. Tindakan ini tidak bisa dibatalkan.',
    },
    'cancel': {'en': 'Cancel', 'id': 'Batal'},
    'reset': {'en': 'Reset', 'id': 'Reset'},
    'reset_done': {'en': 'All progress has been reset', 'id': 'Semua progres telah direset'},

    // ─── Statistics ───────────────────────────────────────
    'overview': {'en': 'Overview', 'id': 'Ringkasan'},
    'puzzles_solved': {'en': 'Puzzles Solved', 'id': 'Teka-teki Selesai'},
    'stars_earned': {'en': 'Stars Earned', 'id': 'Bintang Didapat'},
    'total_time': {'en': 'Total Time', 'id': 'Total Waktu'},
    'best_time': {'en': 'Best Time', 'id': 'Waktu Terbaik'},
    'campaign_progress': {'en': 'Campaign Progress', 'id': 'Progres Kampanye'},
    'levels': {'en': 'Levels', 'id': 'Level'},
    'quick_play': {'en': 'Quick Play', 'id': 'Main Cepat'},
    'total_hints_used': {'en': 'Total Hints Used', 'id': 'Total Petunjuk Digunakan'},
    'best_score': {'en': 'Best Score', 'id': 'Skor Terbaik'},
    'games_played': {'en': 'Games Played', 'id': 'Game Dimainkan'},
    'total_solved': {'en': 'Total Solved', 'id': 'Total Selesai'},
    'avg_per_game': {'en': 'Avg per Game', 'id': 'Rata-rata per Game'},
    'time_attack_empty': {
      'en': 'Play Time Attack to see your stats here!',
      'id': 'Main Time Attack untuk melihat statistik di sini!',
    },

    // ─── Time Attack ──────────────────────────────────────
    'time_attack_title': {'en': 'Time Attack', 'id': 'Serangan Waktu'},
    'time_attack_desc': {
      'en': 'Solve as many puzzles as you can\nin 60 seconds!',
      'id': 'Selesaikan sebanyak mungkin teka-teki\ndalam 60 detik!',
    },
    'bonus_time': {'en': '+5 seconds bonus per solve!', 'id': '+5 detik bonus per soal!'},
    'start': {'en': 'START', 'id': 'MULAI'},
    'times_up': {'en': "TIME'S UP!", 'id': 'WAKTU HABIS!'},
    'new_best': {'en': 'NEW BEST!', 'id': 'REKOR BARU!'},
    'puzzles_solved_count': {'en': 'PUZZLES SOLVED', 'id': 'SOAL TERPECAHKAN'},
    'again': {'en': 'Again', 'id': 'Lagi'},

    // ─── How to Play ──────────────────────────────────────
    'how_to_play_title': {'en': 'HOW TO PLAY', 'id': 'CARA BERMAIN'},
    'goal': {'en': 'Goal', 'id': 'Tujuan'},
    'rules': {'en': 'Rules', 'id': 'Aturan'},
    'star_rating': {'en': 'Star Rating', 'id': 'Rating Bintang'},
    'tips_hints': {'en': 'Tips & Hints', 'id': 'Tips & Petunjuk'},
    'next': {'en': 'Next', 'id': 'Lanjut'},
    'got_it': {'en': 'Got It!', 'id': 'Mengerti!'},

    // ─── Share ────────────────────────────────────────────
    'share_text_header': {'en': 'CountiQ — Target:', 'id': 'CountiQ — Target:'},
    'share_no_hints': {'en': 'No hints!', 'id': 'Tanpa petunjuk!'},
    'share_cta': {'en': 'Can you solve it? #CountiQ #MathPuzzle', 'id': 'Bisakah kamu memecahkannya? #CountiQ #MathPuzzle'},
  };

  /// Get a localized string by key. Falls back to English.
  static String get(String key) {
    final map = _strings[key];
    if (map == null) return key;
    return map[_locale] ?? map['en'] ?? key;
  }

  /// Convenience getters for the most commonly used strings
  static String get appName => get('app_name');
  static String get appSubtitle => get('app_subtitle');
  static String get play => get('play');
  static String get target => get('target');
  static String get targetReached => get('target_reached');
  static String get tapToStart => get('tap_to_start');
  static String get hint => get('hint');
  static String get skip => get('skip');
  static String get home => get('home');
  static String get share => get('share');
  static String get replay => get('replay');
  static String get puzzleSolved => get('puzzle_solved');
  static String get nextPuzzle => get('next_puzzle');
  static String get dailyChallenge => get('daily_challenge');
  static String get dailyComplete => get('daily_complete');
  static String get settings => get('settings');
}
