import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────
//  APP COLORS — dual theme support
//  Static constants = light mode defaults (backward compat)
//  Adaptive methods = context-aware (use in new/updated widgets)
// ─────────────────────────────────────────────────────────────────────

class AppColors {
  // ── Brand ─────────────────────────────────────────
  static const primary      = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark  = Color(0xFF3730A3);
  static const secondary    = Color(0xFF0EA5E9);
  static const accent       = Color(0xFF8B5CF6);

  // ── Status ────────────────────────────────────────
  static const success  = Color(0xFF22C55E);
  static const warning  = Color(0xFFF59E0B);
  static const danger   = Color(0xFFEF4444);
  static const info     = Color(0xFF6366F1);
  static const election = Color(0xFF7C3AED);

  // ── Static constants (backward compat — light mode) ──
  static const background  = Color(0xFFF8FAFC);
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceAlt  = Color(0xFFF1F5F9);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const textPrimary  = Color(0xFF0F172A);
  static const textSecondary= Color(0xFF64748B);
  static const textMuted    = Color(0xFF94A3B8);
  static const textInverse  = Color(0xFFFFFFFF);
  static const border      = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // ── Dark palette ──────────────────────────────────
  static const _darkBg        = Color(0xFF0F172A);
  static const _darkSurface   = Color(0xFF1E293B);
  static const _darkSurfaceAlt= Color(0xFF334155);
  static const _darkText      = Color(0xFFF1F5F9);
  static const _darkTextSec   = Color(0xFF94A3B8);
  static const _darkTextMuted = Color(0xFF64748B);
  static const _darkBorder    = Color(0xFF334155);
  static const _darkBorderLt  = Color(0xFF1E293B);

  // ── Division colors ───────────────────────────────
  static const divProgrammer  = Color(0xFF6366F1);
  static const divHumas       = Color(0xFF10B981);
  static const divITSupport   = Color(0xFFF59E0B);
  static const divTraining    = Color(0xFF8B5CF6);
  static const divBidangUsaha = Color(0xFFEF4444);
  static const divBPH         = Color(0xFF0891B2);

  static Color getDivisionColor(String division) {
    switch (division) {
      case 'Pemrograman':         return divProgrammer;
      case 'Hubungan Masyarakat': return divHumas;
      case 'IT Support':          return divITSupport;
      case 'Training':            return divTraining;
      case 'Bidang Usaha':        return divBidangUsaha;
      case 'Badan Pengurus Harian': return divBPH;
      default:                    return primary;
    }
  }

  static IconData getDivisionIcon(String division) {
    switch (division) {
      case 'Pemrograman':         return Icons.code_rounded;
      case 'Hubungan Masyarakat': return Icons.people_alt_rounded;
      case 'IT Support':          return Icons.computer_rounded;
      case 'Training':            return Icons.school_rounded;
      case 'Bidang Usaha':        return Icons.storefront_rounded;
      case 'Badan Pengurus Harian': return Icons.admin_panel_settings_rounded;
      default:                    return Icons.folder_rounded;
    }
  }

  // ── Adaptive getters (dark-mode aware) ────────────
  static bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext c)  => isDark(c) ? _darkBg        : background;
  static Color surfaceOf(BuildContext c)     => isDark(c) ? _darkSurface   : surface;
  static Color surfaceAltOf(BuildContext c)  => isDark(c) ? _darkSurfaceAlt: surfaceAlt;
  static Color textPrimaryOf(BuildContext c) => isDark(c) ? _darkText      : textPrimary;
  static Color textSecondaryOf(BuildContext c)=> isDark(c)? _darkTextSec   : textSecondary;
  static Color textMutedOf(BuildContext c)   => isDark(c) ? _darkTextMuted : textMuted;
  static Color borderOf(BuildContext c)      => isDark(c) ? _darkBorder    : border;
  static Color borderLightOf(BuildContext c) => isDark(c) ? _darkBorderLt  : borderLight;
  static Color cardShadowOf(BuildContext c)  => isDark(c) ? Colors.black26 : Colors.black.withValues(alpha: 0.04);
}

// ─────────────────────────────────────────────────────────────────────
//  THEME BUILDER
// ─────────────────────────────────────────────────────────────────────

class AppTheme {
  static const divisions = [
    'Pemrograman',
    'Hubungan Masyarakat',
    'IT Support',
    'Training',
    'Bidang Usaha',
    'Badan Pengurus Harian',
  ];

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg        = isDark ? AppColors._darkBg        : AppColors.background;
    final surf      = isDark ? AppColors._darkSurface   : AppColors.surface;
    final surfAlt   = isDark ? AppColors._darkSurfaceAlt: AppColors.surfaceAlt;
    final text      = isDark ? AppColors._darkText      : AppColors.textPrimary;
    final textSec   = isDark ? AppColors._darkTextSec   : AppColors.textSecondary;
    final textMut   = isDark ? AppColors._darkTextMuted : AppColors.textMuted;
    final brd       = isDark ? AppColors._darkBorder    : AppColors.border;
    final brdLt     = isDark ? AppColors._darkBorderLt  : AppColors.borderLight;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: surf,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );

    return base.copyWith(
      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: isDark ? 1 : 0.5,
        shadowColor: brd,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: text, letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: text, size: 22),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: surf,
        elevation: isDark ? 2 : 6,
        shadowColor: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: brdLt, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: brd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: brd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.danger)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: GoogleFonts.inter(color: textMut, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSec, fontSize: 14),
        prefixIconColor: textMut,
        suffixIconColor: textMut,
      ),

      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── FAB ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        elevation: isDark ? 4 : 2,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),

      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: surfAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: BorderSide(color: brd),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dividerTheme: DividerThemeData(color: brd, thickness: 1, space: 0),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark ? AppColors._darkSurfaceAlt : AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: surf,
        elevation: 12,
        shadowColor: isDark ? Colors.black54 : Colors.black.withValues(alpha: 0.1),
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: textSec, height: 1.5),
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        elevation: 8, clipBehavior: Clip.antiAlias,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
      ),

      // ── Tab Bar ──
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary, unselectedLabelColor: textMut,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary, indicatorSize: TabBarIndicatorSize.label,
        dividerColor: brd,
      ),

      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4, shadowColor: isDark ? Colors.black38 : Colors.black12,
        color: surf, textStyle: GoogleFonts.inter(fontSize: 13, color: text),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : textMut),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.primary : brd),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: surf, elevation: isDark ? 4 : 8,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
      ),
    );
  }
}
