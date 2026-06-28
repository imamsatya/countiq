import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _TutorialPage(
      icon: '🎯',
      title: 'Reach the Target',
      description:
          'You are given a TARGET number and a set of available numbers. '
          'Your goal is to combine the available numbers using math operations '
          'to reach the exact target.',
      example: 'Target: 120\nNumbers: 75, 5, 8, 7, 6, 2',
    ),
    _TutorialPage(
      icon: '🔢',
      title: 'How to Play',
      description:
          '1. Tap a number to select it\n'
          '2. Tap an operator (+, −, ×, ÷)\n'
          '3. Tap a second number\n'
          '4. The result replaces both numbers\n'
          '5. Repeat until you reach the target!',
      example: '75 ÷ 5 = 15\n15 × 8 = 120 ✓',
    ),
    _TutorialPage(
      icon: '⚠️',
      title: 'Rules',
      description:
          '• Each number can only be used ONCE\n'
          '• You don\'t have to use all numbers\n'
          '• Only +, −, ×, ÷ are allowed\n'
          '• No fractions (5÷2 = ✗)\n'
          '• No negatives (3−8 = ✗)\n'
          '• Results must be positive integers',
      example: '5 ÷ 2 = 2.5 ✗\n3 − 8 = −5 ✗',
    ),
    _TutorialPage(
      icon: '⭐',
      title: 'Star Rating',
      description:
          'Your performance is rated with stars:\n\n'
          '⭐⭐⭐ Solve quickly, no hints\n'
          '⭐⭐ Solve with few hints or moderate time\n'
          '⭐ Solve the puzzle (any method)',
      example: 'Faster solve + fewer hints = more stars!',
    ),
    _TutorialPage(
      icon: '💡',
      title: 'Tips & Hints',
      description:
          '• Use the HINT button if you\'re stuck — it shows one step from the solution\n'
          '• Use UNDO to go back one step\n'
          '• Use RESET to start over\n'
          '• Look for multiplication & division first — they make bigger jumps!',
      example: 'Tip: 75 ÷ 5 = 15, then 15 × 8 = 120 🎉',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration:
                            AppTheme.glassDecoration(borderRadius: 12),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'How to Play',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) =>
                      _buildPage(_pages[index]),
                ),
              ),

              // Dots + navigation
              _buildBottomNav(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(page.icon, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              page.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          // Example box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.surfaceColor.withValues(alpha: 0.7),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15)),
            ),
            child: Text(
              page.example,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Dots
          Expanded(
            child: Row(
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? AppTheme.primaryColor
                        : AppTheme.surfaceLight,
                  ),
                ),
              ),
            ),
          ),

          // Next / Got it button
          GestureDetector(
            onTap: () {
              if (isLast) {
                context.canPop() ? context.pop() : context.go('/');
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: isLast
                  ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                  : AppTheme.glassDecoration(
                      borderRadius: 14,
                      borderColor:
                          AppTheme.primaryColor.withValues(alpha: 0.3)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'Got It!' : 'Next',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLast
                          ? const Color(0xFF0A0E1A)
                          : AppTheme.primaryColor,
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryColor, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialPage {
  final String icon;
  final String title;
  final String description;
  final String example;

  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.example,
  });
}
