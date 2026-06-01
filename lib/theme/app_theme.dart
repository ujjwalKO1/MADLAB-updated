import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Color(0xFF00BFA6);
  static const Color primaryTealLight = Color(0xFFE0F7F3);
  static const Color primaryTealDark = Color(0xFF009688);
  static const Color accentViolet = Color(0xFF7C4DFF);
  static const Color accentVioletLight = Color(0xFFEDE7F6);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color backgroundWhite = Color(0xFFFAFBFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color panelGray = Color(0xFFF5F6F8);
  static const Color borderGray = Color(0xFFE8ECF0);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color iconGray = Color(0xFFB0B8C4);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color registrationTag = Color(0xFF2979FF);
  static const Color registrationTagBg = Color(0xFFE3F2FD);
  static const Color volunteerTag = Color(0xFFFF6D00);
  static const Color volunteerTagBg = Color(0xFFFFF3E0);
}

class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> get medium => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 3)),
      ];
  static List<BoxShadow> get elevated => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 12)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
      ];
}

const String _fontFamily = 'Segoe UI';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        secondary: AppColors.accentViolet,
        surface: AppColors.surfaceWhite,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1.0),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderGray, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5)),
        hintStyle: const TextStyle(fontSize: 15, color: AppColors.textTertiary),
        labelStyle: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
