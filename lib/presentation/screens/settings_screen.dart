import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _hapticEnabled;

  @override
  void initState() {
    super.initState();
    final db = LocalDatabase.instance;
    _soundEnabled = db.getSoundEnabled();
    _hapticEnabled = db.getHapticEnabled();
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
              _buildHeader(context),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Game section
                    _buildSectionTitle('Game'),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound Effects',
                      value: _soundEnabled,
                      onChanged: (val) {
                        setState(() => _soundEnabled = val);
                        LocalDatabase.instance.setSoundEnabled(val);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildToggleItem(
                      icon: Icons.vibration_rounded,
                      label: 'Haptic Feedback',
                      value: _hapticEnabled,
                      onChanged: (val) {
                        setState(() => _hapticEnabled = val);
                        LocalDatabase.instance.setHapticEnabled(val);
                      },
                    ),

                    const SizedBox(height: 24),

                    // About section
                    _buildSectionTitle('About'),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    const SizedBox(height: 8),
                    _buildTapItem(
                      icon: Icons.star_border_rounded,
                      label: 'Rate This App',
                      onTap: () {
                        // TODO: Open store page
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTapItem(
                      icon: Icons.share_rounded,
                      label: 'Share with Friends',
                      onTap: () {
                        // TODO: Share app link
                      },
                    ),

                    const SizedBox(height: 24),

                    // Danger zone
                    _buildSectionTitle('Data'),
                    const SizedBox(height: 8),
                    _buildTapItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Reset All Progress',
                      color: AppTheme.errorColor,
                      onTap: () => _showResetDialog(),
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
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassDecoration(borderRadius: 12),
            child: const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38), // Balance
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

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.glassDecoration(borderRadius: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.surfaceLight,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.glassDecoration(borderRadius: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapItem({
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

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset All Progress?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'This will delete all your level progress, stars, and statistics. This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Reset all boxes
              final db = LocalDatabase.instance;
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await db.settingsBox.clear();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('All progress has been reset',
                        style: TextStyle(fontFamily: 'Poppins')),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
                setState(() {
                  _soundEnabled = true;
                  _hapticEnabled = true;
                });
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
