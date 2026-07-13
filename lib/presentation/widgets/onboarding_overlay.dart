import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/datasources/local_database.dart';

/// Full-screen onboarding overlay for first-time users.
/// Shows a 4-slide tutorial covering: Welcome, How It Works, Rules, Ready.
class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingOverlay({super.key, required this.onComplete});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<double> _entryScale;

  // Exit animation
  late AnimationController _exitController;
  late Animation<double> _exitFade;

  // Per-page content animation
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    _exitController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  Future<void> _complete() async {
    await LocalDatabase.instance.markOnboardingDone();
    await _exitController.forward();
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryFade, _exitFade]),
      builder: (context, child) {
        final opacity = _entryFade.value *
            (_exitController.isAnimating ? _exitFade.value : 1.0);
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xF00A0E1A), Color(0xF0111827)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: ScaleTransition(
              scale: _entryScale,
              child: Column(
                children: [
                  // Skip button
                  _buildSkipButton(),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        _buildWelcomePage(),
                        _buildHowItWorksPage(),
                        _buildRulesPage(),
                        _buildReadyPage(),
                      ],
                    ),
                  ),

                  // Bottom navigation
                  _buildBottomNav(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Skip Button ────────────────────────────────────────────

  Widget _buildSkipButton() {
    if (_currentPage == _totalPages - 1) {
      return const SizedBox(height: 48);
    }
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _complete,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Text(
              AppStrings.get('onboarding_skip'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ────────────────────────────────────────

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _currentPage == 0 ? _contentFade : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _currentPage == 0 ? _contentSlide : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0E1A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  AppStrings.get('onboarding_welcome'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                AppStrings.get('onboarding_subtitle'),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Floating math symbols decoration
              _buildMathSymbolsRow(),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMathSymbolsRow() {
    const symbols = ['÷', '×', '+', '−', '=', 'π', '√'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: symbols.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            s,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor.withValues(alpha: 0.25),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Page 2: How It Works ───────────────────────────────────

  Widget _buildHowItWorksPage() {
    return FadeTransition(
      opacity: _currentPage == 1 ? _contentFade : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _currentPage == 1 ? _contentSlide : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Section icon
              _buildSectionIcon('🔢'),
              const SizedBox(height: 20),

              // Title
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  AppStrings.get('onboarding_how_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // Target mockup
              _buildTargetMockup(),

              const SizedBox(height: 20),

              // Steps
              _buildStepRow(1, '👆', AppStrings.get('onboarding_how_step1'), '75'),
              _buildStepRow(2, '➗', AppStrings.get('onboarding_how_step2'), '÷'),
              _buildStepRow(3, '👆', AppStrings.get('onboarding_how_step3'), '5'),
              _buildStepRow(4, '✨', AppStrings.get('onboarding_how_step4'), '= 15'),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetMockup() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceColor.withValues(alpha: 0.8),
            AppTheme.surfaceLight.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TARGET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.accentGradient.createShader(bounds),
            child: const Text(
              '120',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String emoji, String text, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Step number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),

          // Description
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ),

          // Value badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.surfaceColor.withValues(alpha: 0.8),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 3: Rules ──────────────────────────────────────────

  Widget _buildRulesPage() {
    return FadeTransition(
      opacity: _currentPage == 2 ? _contentFade : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _currentPage == 2 ? _contentSlide : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              _buildSectionIcon('⚠️'),
              const SizedBox(height: 20),

              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  AppStrings.get('onboarding_rules_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Rule cards
              _buildRuleCard(
                icon: '☝️',
                text: AppStrings.get('onboarding_rule1'),
                example: '75 → ✓  75 again → ✗',
                color: const Color(0xFF42A5F5),
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: '✅',
                text: AppStrings.get('onboarding_rule2'),
                example: '5 ÷ 2 = 2.5 ✗    3 − 8 = −5 ✗',
                color: const Color(0xFF66BB6A),
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: '🧮',
                text: AppStrings.get('onboarding_rule3'),
                example: '+   −   ×   ÷',
                color: const Color(0xFFAB47BC),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String icon,
    required String text,
    required String example,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  example,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 4: Ready ──────────────────────────────────────────

  Widget _buildReadyPage() {
    return FadeTransition(
      opacity: _currentPage == 3 ? _contentFade : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _currentPage == 3 ? _contentSlide : const AlwaysStoppedAnimation(Offset.zero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Celebration emoji
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),

              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  AppStrings.get('onboarding_ready'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppStrings.get('onboarding_ready_desc'),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Feature icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureIcon('⭐', 'Stars'),
                  const SizedBox(width: 24),
                  _buildFeatureIcon('📅', 'Daily'),
                  const SizedBox(width: 24),
                  _buildFeatureIcon('⚡', 'Time Attack'),
                  const SizedBox(width: 24),
                  _buildFeatureIcon('🏆', 'Achievements'),
                ],
              ),

              const Spacer(flex: 2),

              // LET'S GO button
              GestureDetector(
                onTap: _complete,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: AppTheme.primaryGlowDecoration(borderRadius: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Color(0xFF0A0E1A), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.get('onboarding_letsgo'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0E1A),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppTheme.surfaceColor.withValues(alpha: 0.7),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ─── Section Icon Helper ────────────────────────────────────

  Widget _buildSectionIcon(String emoji) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  // ─── Bottom Navigation ──────────────────────────────────────

  Widget _buildBottomNav() {
    final isLast = _currentPage == _totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Dot indicators
          Expanded(
            child: Row(
              children: List.generate(
                _totalPages,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: _currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentPage == i
                        ? AppTheme.primaryGradient
                        : null,
                    color: _currentPage == i
                        ? null
                        : AppTheme.surfaceLight.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // Next button (hidden on last page — we have LET'S GO)
          if (!isLast)
            GestureDetector(
              onTap: () => _goToPage(_currentPage + 1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: AppTheme.glassDecoration(
                  borderRadius: 14,
                  borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.get('next'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryColor, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
