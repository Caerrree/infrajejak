import 'package:flutter/material.dart';
import '../models/hazard.dart';

/// Design tokens for Infra Jejak. Keeping colors/spacing centralised here
/// makes it easy to keep every screen visually consistent (Section 25).
class AppColors {
  static const primary = Color(0xFF0B5D3B);
  static const primaryLight = Color(0xFFE7F3EC);
  static const accent = Color(0xFFF2A93B);
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1B1F23);
  static const textMuted = Color(0xFF6B7280);

  static const severityLow = Color(0xFF2E9E5B);
  static const severityMedium = Color(0xFFE0A020);
  static const severityHigh = Color(0xFFD1453B);

  static const official = Color(0xFF1D4ED8);
  static const community = Color(0xFF9333EA);

  static Color forSeverity(HazardSeverity s) {
    switch (s) {
      case HazardSeverity.low:
        return severityLow;
      case HazardSeverity.medium:
        return severityMedium;
      case HazardSeverity.high:
        return severityHigh;
    }
  }

  static Color forStatus(HazardStatus s) {
    switch (s) {
      case HazardStatus.reported:
        return Colors.grey;
      case HazardStatus.underReview:
        return const Color(0xFFE0A020);
      case HazardStatus.communityVerified:
        return const Color(0xFF9333EA);
      case HazardStatus.acknowledged:
        return const Color(0xFF1D4ED8);
      case HazardStatus.repairing:
        return const Color(0xFFF97316);
      case HazardStatus.resolved:
        return const Color(0xFF2E9E5B);
      case HazardStatus.rejected:
        return const Color(0xFFD1453B);
    }
  }
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E5E9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
        bodySmall: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
