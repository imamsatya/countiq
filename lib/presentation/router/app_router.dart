import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/result_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/campaign_game_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/daily_challenge_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/time_attack_screen.dart';
import '../screens/dev_mode_screen.dart';

/// Smooth slide-fade transition for all routes
CustomTransitionPage<void> _transitionPage({
  required Widget child,
  required GoRouterState state,
  bool slideUp = false,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final offset = slideUp
          ? Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          : Tween(begin: const Offset(0.05, 0), end: Offset.zero);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: offset.animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _transitionPage(child: const HomeScreen(), state: state),
    ),
    GoRoute(
      path: '/game/:difficulty',
      pageBuilder: (context, state) {
        final difficulty = state.pathParameters['difficulty'] ?? 'easy';
        // Use a unique key so re-navigation always creates a fresh game
        return _transitionPage(
          child: GameScreen(
            key: ValueKey('game_${difficulty}_${DateTime.now().millisecondsSinceEpoch}'),
            difficulty: difficulty,
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/levels',
      pageBuilder: (context, state) =>
          _transitionPage(child: const LevelSelectScreen(), state: state),
    ),
    GoRoute(
      path: '/campaign/:level',
      pageBuilder: (context, state) {
        final level = int.parse(state.pathParameters['level']!);
        return _transitionPage(
          child: CampaignGameScreen(levelNumber: level),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/result',
      pageBuilder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        return _transitionPage(
          child: ResultScreen(
            timeSeconds: extras['time'] ?? 0,
            stepsCount: extras['steps'] ?? 0,
            hintsUsed: extras['hints'] ?? 0,
            stars: extras['stars'] ?? 1,
            difficulty: extras['difficulty'] ?? 'easy',
            target: extras['target'] ?? 0,
            campaignLevel: extras['levelNumber'],
            solutionSteps: extras['solutionSteps'] ?? const [],
          ),
          state: state,
          slideUp: true,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _transitionPage(child: const SettingsScreen(), state: state),
    ),
    GoRoute(
      path: '/statistics',
      pageBuilder: (context, state) =>
          _transitionPage(child: const StatisticsScreen(), state: state),
    ),
    GoRoute(
      path: '/daily',
      pageBuilder: (context, state) =>
          _transitionPage(child: const DailyChallengeScreen(), state: state),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (context, state) =>
          _transitionPage(child: const AchievementsScreen(), state: state),
    ),
    GoRoute(
      path: '/how-to-play',
      pageBuilder: (context, state) =>
          _transitionPage(child: const HowToPlayScreen(), state: state),
    ),
    GoRoute(
      path: '/time-attack',
      pageBuilder: (context, state) =>
          _transitionPage(child: const TimeAttackScreen(), state: state),
    ),
    GoRoute(
      path: '/dev',
      pageBuilder: (context, state) =>
          _transitionPage(child: const DevModeScreen(), state: state),
    ),
  ],
);
