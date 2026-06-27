import 'package:flutter/material.dart';

/// CountiQ Theme - Cyan/Teal identity
/// Dark glassmorphism with electric blue accents
class AppTheme {
  AppTheme._();

  // Primary Colors — Cyan/Teal identity
  static const Color primaryColor = Color(0xFF00E5FF);
  static const Color secondaryColor = Color(0xFF00BCD4);
  static const Color accentColor = Color(0xFF18FFFF);

  // Status Colors
  static const Color successColor = Color(0xFF00C9A7);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFFA726);

  // Background Colors — Deep dark blue
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color backgroundLight = Color(0xFF111827);
  static const Color surfaceColor = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFF243447);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);

  // Number tile colors
  static const Color tileDefault = Color(0xFF1E3A5F);
  static const Color tileSelected = Color(0xFF00E5FF);
  static const Color tileUsed = Color(0xFF2A2A3E);
  static const Color tileResult = Color(0xFF00897B);

  // Operator colors
  static const Color operatorAdd = Color(0xFF4CAF50);
  static const Color operatorSub = Color(0xFFFF7043);
  static const Color operatorMul = Color(0xFF42A5F5);
  static const Color operatorDiv = Color(0xFFAB47BC);

  // Difficulty Colors
  static const Color easyColor = Color(0xFF81C784);
  static const Color mediumColor = Color(0xFF64B5F6);
  static const Color hardColor = Color(0xFFFFB74D);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00BCD4), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient targetGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF18FFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism decoration
  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: surfaceColor.withValues(alpha: 0.6),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // Primary glow decoration (for main CTA buttons)
  static BoxDecoration primaryGlowDecoration({double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: primaryGradient,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: -2,
        ),
      ],
    );
  }

  // Number tile decoration
  static BoxDecoration tileDeco({
    bool selected = false,
    bool used = false,
    bool isResult = false,
  }) {
    Color bg = tileDefault;
    Color border = Colors.white.withValues(alpha: 0.08);

    if (used) {
      bg = tileUsed;
      border = Colors.white.withValues(alpha: 0.03);
    } else if (selected) {
      bg = primaryColor.withValues(alpha: 0.15);
      border = primaryColor.withValues(alpha: 0.5);
    } else if (isResult) {
      bg = tileResult.withValues(alpha: 0.2);
      border = tileResult.withValues(alpha: 0.4);
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: bg,
      border: Border.all(color: border, width: 1.5),
      boxShadow: selected
          ? [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: -2,
              )
            ]
          : null,
    );
  }

  /// Get the main theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryColor,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .white
          .apply(
            fontFamily: 'Poppins',
            bodyColor: textPrimary,
            displayColor: textPrimary,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
