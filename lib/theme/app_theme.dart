import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary — Modern Indigo/Violet (Material You feel)
  static const primary     = Color(0xFF4F46E5); // Indigo 600
  static const primaryLight= Color(0xFF818CF8); // Indigo 400
  static const primaryDark = Color(0xFF3730A3); // Indigo 800
  static const secondary   = Color(0xFF0EA5E9);
  static const accent      = Color(0xFF8B5CF6); // Violet

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger  = Color(0xFFEF4444);
  static const info    = Color(0xFF6366F1);
  static const election= Color(0xFF7C3AED);

  // Surfaces — Softer, warmer whites
  static const background  = Color(0xFFF5F5F7); // Apple-ish grey
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceAlt  = Color(0xFFF9FAFB);
  static const surfaceCard = Color(0xFFFFFFFF);

  // Text
  static const textPrimary  = Color(0xFF111827);
  static const textSecondary= Color(0xFF6B7280);
  static const textMuted    = Color(0xFF9CA3AF);
  static const textInverse  = Color(0xFFFFFFFF);

  // Border — lighter for M3
  static const border      = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Division colors — more vibrant
  static const divProgrammer  = Color(0xFF6366F1); // Indigo
  static const divHumas       = Color(0xFF10B981); // Emerald
  static const divITSupport   = Color(0xFFF59E0B); // Amber
  static const divTraining    = Color(0xFF8B5CF6); // Violet
  static const divBidangUsaha = Color(0xFFEF4444); // Red

  static Color getDivisionColor(String division) {
    switch (division) {
      case 'Pemrograman':      return divProgrammer;
      case 'Hubungan Masyarakat': return divHumas;
      case 'IT Support':       return divITSupport;
      case 'Training':         return divTraining;
      case 'Bidang Usaha':     return divBidangUsaha;
      default:                 return primary;
    }
  }

  static IconData getDivisionIcon(String division) {
    switch (division) {
      case 'Pemrograman':      return Icons.code_rounded;
      case 'Hubungan Masyarakat': return Icons.people_alt_rounded;
      case 'IT Support':       return Icons.computer_rounded;
      case 'Training':         return Icons.school_rounded;
      case 'Bidang Usaha':     return Icons.storefront_rounded;
      default:                 return Icons.folder_rounded;
    }
  }
}

class AppTheme {
  static const divisions = [
    'Pemrograman',
    'Hubungan Masyarakat',
    'IT Support',
    'Training',
    'Bidang Usaha',
  ];

  static ThemeData get lightTheme {
    // Override status bar to be transparent for immersive look
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );

    return base.copyWith(
      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),

      // ── Cards ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input Fields ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),

      // ── Elevated Button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      // ── Text Button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // ── Chips ────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black12,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 8,
        clipBehavior: Clip.antiAlias,
      ),

      // ── ListTile ─────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
      ),

      // ── Tab Bar ──────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
      ),

      // ── Popup Menu ───────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black12,
        color: Colors.white,
        textStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
      ),

      // ── Drawer ───────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),
    );
  }
}
