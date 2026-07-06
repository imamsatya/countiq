import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';

/// Developer mode screen for testing and reviewing all levels.
/// Access via Settings screen by tapping version 5 times.
class DevModeScreen extends StatefulWidget {
  const DevModeScreen({super.key});

  @override
  State<DevModeScreen> createState() => _DevModeScreenState();
}

class _DevModeScreenState extends State<DevModeScreen> {
  int _selectedCampaignLevel = 1;
  String _selectedDifficulty = 'easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Dev badge
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.orange.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.developer_mode_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'DEV MODE — For Testing Only',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ──── Campaign Levels ────
                    _buildSectionTitle('Campaign Levels'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassDecoration(borderRadius: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flag_rounded, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Level $_selectedCampaignLevel',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _getLevelDifficulty(_selectedCampaignLevel),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getLevelDifficultyColor(_selectedCampaignLevel),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primaryColor,
                              inactiveTrackColor: AppTheme.surfaceLight,
                              thumbColor: AppTheme.primaryColor,
                              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                            ),
                            child: Slider(
                              value: _selectedCampaignLevel.toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              onChanged: (val) {
                                setState(() => _selectedCampaignLevel = val.round());
                              },
                            ),
                          ),
                          // Quick jump row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [1, 10, 25, 50, 75, 100].map((lvl) {
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCampaignLevel = lvl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: _selectedCampaignLevel == lvl
                                        ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                        : AppTheme.surfaceLight.withValues(alpha: 0.3),
                                    border: Border.all(
                                      color: _selectedCampaignLevel == lvl
                                          ? AppTheme.primaryColor.withValues(alpha: 0.5)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    '$lvl',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedCampaignLevel == lvl
                                          ? AppTheme.primaryColor
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          _buildPlayButton(
                            label: 'PLAY LEVEL $_selectedCampaignLevel',
                            onTap: () => context.push('/campaign/$_selectedCampaignLevel'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ──── Quick Play ────
                    _buildSectionTitle('Quick Play'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassDecoration(borderRadius: 16),
                      child: Column(
                        children: [
                          Row(
                            children: ['easy', 'medium', 'hard'].map((diff) {
                              final isSelected = _selectedDifficulty == diff;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedDifficulty = diff),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                          : AppTheme.surfaceLight.withValues(alpha: 0.3),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryColor.withValues(alpha: 0.5)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        diff.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          _buildPlayButton(
                            label: 'PLAY ${_selectedDifficulty.toUpperCase()}',
                            onTap: () => context.push('/game/$_selectedDifficulty'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ──── Other Modes ────
                    _buildSectionTitle('Other Modes'),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.today_rounded,
                      label: 'Daily Challenge',
                      color: AppTheme.primaryColor,
                      onTap: () => context.push('/daily'),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.bolt_rounded,
                      label: 'Time Attack',
                      color: Colors.orange,
                      onTap: () => context.push('/time-attack'),
                    ),

                    const SizedBox(height: 20),

                    // ──── Screens ────
                    _buildSectionTitle('Screens'),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Level Select',
                      onTap: () => context.push('/levels'),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.emoji_events_rounded,
                      label: 'Achievements',
                      onTap: () => context.push('/achievements'),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Statistics',
                      onTap: () => context.push('/statistics'),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.help_outline_rounded,
                      label: 'How to Play',
                      onTap: () => context.push('/how-to-play'),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () => context.push('/settings'),
                    ),

                    const SizedBox(height: 20),

                    // ──── Data Tools ────
                    _buildSectionTitle('Data Tools'),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.add_chart_rounded,
                      label: 'Unlock All Levels (set progress to 100)',
                      color: AppTheme.successColor,
                      onTap: () async {
                        final db = LocalDatabase.instance;
                        final messenger = ScaffoldMessenger.of(context);
                        for (int i = 1; i <= 100; i++) {
                          await db.saveLevelCompletion(
                            levelNumber: i,
                            stars: 3,
                            timeSeconds: 30,
                            steps: 2,
                            hints: 0,
                          );
                        }
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('✅ All 100 levels unlocked with 3 stars'),
                            backgroundColor: AppTheme.successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.delete_sweep_rounded,
                      label: 'Reset ALL Data',
                      color: AppTheme.errorColor,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await LocalDatabase.instance.resetAll();
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('🗑️ All data wiped'),
                            backgroundColor: AppTheme.errorColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.developer_mode_rounded, color: Colors.orange, size: 18),
                SizedBox(width: 6),
                Text(
                  'DEV MODE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildPlayButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: AppTheme.primaryGlowDecoration(borderRadius: 14),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0E1A),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.glassDecoration(borderRadius: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppTheme.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  String _getLevelDifficulty(int level) {
    if (level <= 20) return 'EASY';
    if (level <= 50) return 'MEDIUM';
    if (level <= 80) return 'HARD';
    return 'EXPERT';
  }

  Color _getLevelDifficultyColor(int level) {
    if (level <= 20) return AppTheme.easyColor;
    if (level <= 50) return AppTheme.mediumColor;
    if (level <= 80) return AppTheme.hardColor;
    return AppTheme.errorColor;
  }
}
