import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1E40AF);
  static const secondary = Color(0xFF0EA5E9);
  static const accent = Color(0xFF06B6D4);

  // Status
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF6366F1);
  static const election = Color(0xFF7C3AED);

  // Surfaces
  static const background = Color(0xFFF1F5F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const textInverse = Color(0xFFFFFFFF);

  // Border
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Division colors
  static const divProgrammer = Color(0xFF3B82F6);
  static const divHumas = Color(0xFF10B981);
  static const divITSupport = Color(0xFFF59E0B);
  static const divTraining = Color(0xFF8B5CF6);
  static const divBidangUsaha = Color(0xFFEF4444);

  static Color getDivisionColor(String division) {
    switch (division) {
      case 'Programmer':
        return divProgrammer;
      case 'Hubungan Masyarakat':
        return divHumas;
      case 'IT Support':
        return divITSupport;
      case 'Training':
        return divTraining;
      case 'Bidang Usaha':
        return divBidangUsaha;
      default:
        return primary;
    }
  }

  static IconData getDivisionIcon(String division) {
    switch (division) {
      case 'Programmer':
        return Icons.code_rounded;
      case 'Hubungan Masyarakat':
        return Icons.people_rounded;
      case 'IT Support':
        return Icons.support_agent_rounded;
      case 'Training':
        return Icons.school_rounded;
      case 'Bidang Usaha':
        return Icons.business_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}

class AppTheme {
  static const divisions = [
    'Programmer',
    'Hubungan Masyarakat',
    'IT Support',
    'Training',
    'Bidang Usaha',
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
