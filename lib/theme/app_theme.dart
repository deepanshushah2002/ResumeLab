import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors (shared) ────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1B4FE4);
  static const Color primaryLight = Color(0xFF4B75F0);
  static const Color primaryDark  = Color(0xFF0E2FA8);
  static const Color accent       = Color(0xFF00C7BE);
  static const Color success      = Color(0xFF22C55E);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color error        = Color(0xFFEF4444);

  // ─── Light Palette ────────────────────────────────────────────────────────
  static const Color lightSurface    = Color(0xFFF8F9FF);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightTextDark   = Color(0xFF0D1B3E);
  static const Color lightTextMedium = Color(0xFF4A5568);
  static const Color lightTextLight  = Color(0xFF8899AA);
  static const Color lightBorder     = Color(0xFFE2E8F0);
  static const Color lightInput      = Color(0xFFFFFFFF);

  // ─── Dark Palette ─────────────────────────────────────────────────────────
  static const Color darkSurface    = Color(0xFF0F1117);
  static const Color darkCard       = Color(0xFF1A1D27);
  static const Color darkTextDark   = Color(0xFFF0F4FF);
  static const Color darkTextMedium = Color(0xFFB0BBCC);
  static const Color darkTextLight  = Color(0xFF6B7A90);
  static const Color darkBorder     = Color(0xFF2A2F3D);
  static const Color darkInput      = Color(0xFF20243A);

  // ─── Context-aware helpers ────────────────────────────────────────────────
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceColor(BuildContext context) =>
      isDarkMode(context) ? darkSurface : lightSurface;

  static Color cardColor(BuildContext context) =>
      isDarkMode(context) ? darkCard : lightCard;

  static Color textDarkColor(BuildContext context) =>
      isDarkMode(context) ? darkTextDark : lightTextDark;

  static Color textMediumColor(BuildContext context) =>
      isDarkMode(context) ? darkTextMedium : lightTextMedium;

  static Color textLightColor(BuildContext context) =>
      isDarkMode(context) ? darkTextLight : lightTextLight;

  static Color borderColor(BuildContext context) =>
      isDarkMode(context) ? darkBorder : lightBorder;

  static Color inputFillColor(BuildContext context) =>
      isDarkMode(context) ? darkInput : lightInput;

  // Legacy static refs (kept for compatibility – use context helpers where possible)
  static const Color surface    = lightSurface;
  static const Color card       = lightCard;
  static const Color textDark   = lightTextDark;
  static const Color textMedium = lightTextMedium;
  static const Color textLight  = lightTextLight;
  static const Color border     = lightBorder;

  // ─── Theme factory ────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark  = brightness == Brightness.dark;
    final bg      = isDark ? darkSurface    : lightSurface;
    final cardCol = isDark ? darkCard       : lightCard;
    final txtDark = isDark ? darkTextDark   : lightTextDark;
    final txtMid  = isDark ? darkTextMedium : lightTextMedium;
    final txtLite = isDark ? darkTextLight  : lightTextLight;
    final brd     = isDark ? darkBorder     : lightBorder;
    final inputBg = isDark ? darkInput      : lightInput;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: accent,
        error: error,
      ).copyWith(
        surface: bg,
        onSurface: txtDark,
        surfaceContainerLow: cardCol,
        surfaceContainer: cardCol,
        surfaceContainerHigh: cardCol,
      ),
      scaffoldBackgroundColor: bg,

      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge:  GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w700, color: txtDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w700, color: txtDark),
        headlineLarge: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w700, color: txtDark),
        headlineMedium:GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: txtDark),
        titleLarge:    GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: txtDark),
        bodyLarge:     GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: txtMid),
        bodyMedium:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: txtMid),
        labelLarge:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: txtDark),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cardCol,
        foregroundColor: txtDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: txtDark),
        iconTheme: IconThemeData(color: txtDark),
      ),

      cardTheme: CardThemeData(
        color: cardCol,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: brd, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: brd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: brd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error)),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: txtMid),
        hintStyle:  GoogleFonts.dmSans(fontSize: 14, color: txtLite),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.1),
        selectedColor: primary,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      dividerTheme: DividerThemeData(color: brd, thickness: 1, space: 1),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardCol,
        modalBackgroundColor: cardCol,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : txtLite,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary.withOpacity(0.4) : brd,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: txtLite,
        indicatorColor: primary,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cardCol),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: brd),
            ),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: cardCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: brd),
        ),
      ),
    );
  }
}