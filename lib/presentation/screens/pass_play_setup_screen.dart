import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/locale_provider.dart';

/// Setup screen for Pass & Play mode — configure players, rounds, difficulty.
class PassPlaySetupScreen extends ConsumerStatefulWidget {
  const PassPlaySetupScreen({super.key});

  @override
  ConsumerState<PassPlaySetupScreen> createState() => _PassPlaySetupScreenState();
}

class _PassPlaySetupScreenState extends ConsumerState<PassPlaySetupScreen> {
  int _playerCount = 2;
  int _selectedRounds = 3;
  String _selectedDifficulty = 'medium';
  int _timeLimit = 120;
  final List<TextEditingController> _nameControllers = [];

  final _roundOptions = [3, 5, 7];
  final _diffOptions = ['easy', 'medium', 'hard'];
  final _timeLimitOptions = [60, 90, 120, 180, 0]; // 0 = no limit

  @override
  void initState() {
    super.initState();
    _updateNameControllers();
  }

  void _updateNameControllers() {
    while (_nameControllers.length < _playerCount) {
      _nameControllers.add(TextEditingController(
          text: '${AppStrings.get('pp_player')} ${_nameControllers.length + 1}'));
    }
    while (_nameControllers.length > _playerCount) {
      _nameControllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();
    // Ensure no empty names
    for (int i = 0; i < names.length; i++) {
      if (names[i].isEmpty) names[i] = '${AppStrings.get('pp_player')} ${i + 1}';
    }
    context.push('/pass-play/game', extra: {
      'playerCount': _playerCount,
      'playerNames': names,
      'totalRounds': _selectedRounds,
      'difficulty': _selectedDifficulty,
      'timeLimitSeconds': _timeLimit,
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.canPop() ? context.pop() : context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppTheme.glassDecoration(borderRadius: 12),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const Spacer(),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: Text(AppStrings.get('pp_title'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38), // balance
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Players count
                        _buildSectionTitle(AppStrings.get('pp_players')),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(3, (i) {
                            final count = i + 2; // 2, 3, 4
                            final isSelected = _playerCount == count;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _playerCount = count;
                                  _updateNameControllers();
                                }),
                                child: Container(
                                  margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: isSelected
                                      ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                                      : AppTheme.glassDecoration(borderRadius: 14),
                                  child: Center(
                                    child: Text('$count',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? const Color(0xFF0A0E1A) : Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        // Player names
                        _buildSectionTitle(AppStrings.get('pp_player_names')),
                        const SizedBox(height: 8),
                        ...List.generate(_playerCount, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              decoration: AppTheme.glassDecoration(borderRadius: 14),
                              child: TextField(
                                controller: _nameControllers[i],
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _playerColor(i).withValues(alpha: 0.2),
                                    ),
                                    child: Center(child: Text('${i + 1}',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                            color: _playerColor(i)))),
                                  ),
                                  hintText: '${AppStrings.get('pp_player')} ${i + 1}',
                                  hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Rounds
                        _buildSectionTitle(AppStrings.get('pp_rounds')),
                        const SizedBox(height: 8),
                        Row(
                          children: _roundOptions.asMap().entries.map((entry) {
                            final isSelected = _selectedRounds == entry.value;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRounds = entry.value),
                                child: Container(
                                  margin: EdgeInsets.only(left: entry.key > 0 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: isSelected
                                      ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                                      : AppTheme.glassDecoration(borderRadius: 14),
                                  child: Center(
                                    child: Text('${entry.value}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? const Color(0xFF0A0E1A) : Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Difficulty
                        _buildSectionTitle(AppStrings.get('pp_difficulty')),
                        const SizedBox(height: 8),
                        Row(
                          children: _diffOptions.asMap().entries.map((entry) {
                            final isSelected = _selectedDifficulty == entry.value;
                            final dots = {'easy': '🟢', 'medium': '🟡', 'hard': '🔴'};
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedDifficulty = entry.value),
                                child: Container(
                                  margin: EdgeInsets.only(left: entry.key > 0 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: isSelected
                                      ? AppTheme.primaryGlowDecoration(borderRadius: 14)
                                      : AppTheme.glassDecoration(borderRadius: 14),
                                  child: Center(
                                    child: Text('${dots[entry.value]} ${AppStrings.get(entry.value)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? const Color(0xFF0A0E1A) : Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Time limit
                        _buildSectionTitle(AppStrings.get('pp_time_limit')),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _timeLimitOptions.map((t) {
                            final isSelected = _timeLimit == t;
                            return GestureDetector(
                              onTap: () => setState(() => _timeLimit = t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: isSelected
                                    ? AppTheme.primaryGlowDecoration(borderRadius: 12)
                                    : AppTheme.glassDecoration(borderRadius: 12),
                                child: Text(
                                  t == 0 ? '∞' : '${t}s',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFF0A0E1A) : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Start button
                GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: AppTheme.primaryGlowDecoration(borderRadius: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Color(0xFF0A0E1A), size: 28),
                        const SizedBox(width: 8),
                        Text(AppStrings.get('pp_start').toUpperCase(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0E1A), letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary.withValues(alpha: 0.7), letterSpacing: 1));
  }

  Color _playerColor(int index) {
    const colors = [
      AppTheme.primaryColor,
      Colors.orangeAccent,
      Color(0xFF9C27B0),
      AppTheme.successColor,
    ];
    return colors[index % colors.length];
  }
}
