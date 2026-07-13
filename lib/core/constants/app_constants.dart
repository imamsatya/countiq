/// Application-wide constants for CountiQ
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CountiQ';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.countiq.app';
  static const String contactEmail = 'sortiq.app@gmail.com';
  static const String privacyPolicyUrl = 'https://countiq-privacy.vercel.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.countiq.app';

  // ⚡ Developer Mode — set to false before production/Play Store release!
  static const bool devMode = true; // Shows Dev Mode button in settings
  static const bool devUnlockAllLevels = true; // Unlock all campaign levels for testing

  // Game Config
  static const int totalCampaignLevels = 1200;
  static const int tutorialLevels = 50;   // Levels 1-50
  static const int easyLevels = 150;      // Levels 51-200
  static const int mediumLevels = 300;    // Levels 201-500
  static const int hardLevels = 300;      // Levels 501-800
  static const int expertLevels = 300;    // Levels 801-1100
  static const int masterLevels = 100;    // Levels 1101-1200

  // Numbers Config
  static const List<int> bigNumbers = [25, 50, 75, 100];
  static const int maxBoardNumbers = 6;

  // Time Attack
  static const int timeAttackDurationSeconds = 60;
  static const int timeAttackBonusSeconds = 5;

  // Stars Rating
  static const int threeStarMaxHints = 0; // No hints used
  static const int threeStarMaxTime = 30; // Under 30 seconds
  static const int twoStarMaxHints = 1; // Up to 1 hint
  static const int twoStarMaxTime = 60; // Under 60 seconds
  // 1 star: everything else

  // Daily Challenge
  static const String dailyChallengePrefix = 'daily_';
  static const String dailyBestStreakKey = 'daily_best_streak';

  // Ads — future integration
  static const bool adsEnabled = false; // Enable when AdMob is integrated
  static const int minLevelsBetweenAds = 3;
  static const int minSecondsBetweenAds = 120;
  static const int skipAdsForFirstNLevels = 5;

  // Ad Unit IDs (replace with real IDs before release)
  static const String bannerAdUnitId = '';
  static const String interstitialAdUnitId = '';
  static const String rewardedAdUnitId = '';

  // Hive Box Names
  static const String settingsBoxName = 'countiq_settings';
  static const String statsBoxName = 'countiq_stats';
  static const String levelsBoxName = 'countiq_levels';

  // Settings Keys
  static const String soundKey = 'sound_enabled';
  static const String hapticKey = 'haptic_enabled';
  static const String localeKey = 'locale';

  // IAP Product IDs — future integration
  static const String proProductId = 'com.countiq.pro';

  // Rate App
  static const String rateAppKey = 'rate_app_status';
  static const int rateAppAfterLevels = 10;
}
