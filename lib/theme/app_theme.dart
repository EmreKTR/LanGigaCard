import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fixed spacing scale used everywhere instead of magic numbers.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Fixed corner-radius scale.
class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}

/// The 4 selectable brand accents shown on the Profile > App Preferences >
/// "Theme Color" swatch row.
enum AccentColor { purple, pink, green, orange }

extension AccentColorX on AccentColor {
  Color get seed => switch (this) {
        AccentColor.purple => const Color(0xFF7C4DFF),
        AccentColor.pink => const Color(0xFFFF4081),
        AccentColor.green => const Color(0xFF00C853),
        AccentColor.orange => const Color(0xFFFF6D00),
      };

  String get label => switch (this) {
        AccentColor.purple => 'Purple',
        AccentColor.pink => 'Pink',
        AccentColor.green => 'Green',
        AccentColor.orange => 'Orange',
      };
}

/// App-specific design tokens that aren't part of Flutter's ColorScheme,
/// wired through as a proper [ThemeExtension] so every widget gets the
/// right light/dark + accent colors automatically via `context.appColors`.
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceInput,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onPrimary,
    required this.srsAgain,
    required this.srsHard,
    required this.srsMedium,
    required this.srsEasy,
    required this.mastered,
    required this.learning,
    required this.reviewDue,
    required this.streakStart,
    required this.streakEnd,
    required this.success,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceInput;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color onPrimary;
  final Color srsAgain;
  final Color srsHard;
  final Color srsMedium;
  final Color srsEasy;
  final Color mastered;
  final Color learning;
  final Color reviewDue;
  final Color streakStart;
  final Color streakEnd;
  final Color success;
  final Color danger;

  List<Color> get primaryGradient => [primaryLight, primary];
  List<Color> get streakGradient => [streakStart, streakEnd];

  static AppColorsExt light(AccentColor accent) {
    final hsl = HSLColor.fromColor(accent.seed);
    return AppColorsExt(
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFFFF),
      surfaceElevated: const Color(0xFFF3F4F8),
      surfaceInput: const Color(0xFFF8F9FC),
      border: const Color(0xFFE5E7EB),
      textPrimary: const Color(0xFF111827),
      textSecondary: const Color(0xFF6B7280),
      textMuted: const Color(0xFF9CA3AF),
      primary: accent.seed,
      primaryLight: hsl.withLightness((hsl.lightness + 0.14).clamp(0, 1)).toColor(),
      primaryDark: hsl.withLightness((hsl.lightness - 0.14).clamp(0, 1)).toColor(),
      onPrimary: Colors.white,
      srsAgain: const Color(0xFFEF4444),
      srsHard: const Color(0xFFF59E0B),
      srsMedium: const Color(0xFF3B82F6),
      srsEasy: const Color(0xFF10B981),
      mastered: const Color(0xFF10B981),
      learning: const Color(0xFFF59E0B),
      reviewDue: const Color(0xFFEF4444),
      streakStart: const Color(0xFFFBBF24),
      streakEnd: const Color(0xFFF97316),
      success: const Color(0xFF10B981),
      danger: const Color(0xFFEF4444),
    );
  }

  static AppColorsExt dark(AccentColor accent) {
    final hsl = HSLColor.fromColor(accent.seed);
    return AppColorsExt(
      background: const Color(0xFF0A0E1A),
      surface: const Color(0xFF141A2E),
      surfaceElevated: const Color(0xFF1D2540),
      surfaceInput: const Color(0xFF161D33),
      border: const Color(0xFF272F4A),
      textPrimary: const Color(0xFFF8FAFC),
      textSecondary: const Color(0xFF9CA3AF),
      textMuted: const Color(0xFF6B7280),
      primary: hsl.withLightness((hsl.lightness + 0.06).clamp(0, 1)).toColor(),
      primaryLight: hsl.withLightness((hsl.lightness + 0.2).clamp(0, 1)).toColor(),
      primaryDark: hsl.withLightness((hsl.lightness - 0.16).clamp(0, 1)).toColor(),
      onPrimary: Colors.white,
      srsAgain: const Color(0xFFF87171),
      srsHard: const Color(0xFFFBBF24),
      srsMedium: const Color(0xFF60A5FA),
      srsEasy: const Color(0xFF34D399),
      mastered: const Color(0xFF34D399),
      learning: const Color(0xFFFBBF24),
      reviewDue: const Color(0xFFF87171),
      streakStart: const Color(0xFFFBBF24),
      streakEnd: const Color(0xFFF97316),
      success: const Color(0xFF34D399),
      danger: const Color(0xFFF87171),
    );
  }

  @override
  AppColorsExt copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceInput,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? onPrimary,
    Color? srsAgain,
    Color? srsHard,
    Color? srsMedium,
    Color? srsEasy,
    Color? mastered,
    Color? learning,
    Color? reviewDue,
    Color? streakStart,
    Color? streakEnd,
    Color? success,
    Color? danger,
  }) {
    return AppColorsExt(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      srsAgain: srsAgain ?? this.srsAgain,
      srsHard: srsHard ?? this.srsHard,
      srsMedium: srsMedium ?? this.srsMedium,
      srsEasy: srsEasy ?? this.srsEasy,
      mastered: mastered ?? this.mastered,
      learning: learning ?? this.learning,
      reviewDue: reviewDue ?? this.reviewDue,
      streakStart: streakStart ?? this.streakStart,
      streakEnd: streakEnd ?? this.streakEnd,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsExt(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      surfaceInput: l(surfaceInput, other.surfaceInput),
      border: l(border, other.border),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      primary: l(primary, other.primary),
      primaryLight: l(primaryLight, other.primaryLight),
      primaryDark: l(primaryDark, other.primaryDark),
      onPrimary: l(onPrimary, other.onPrimary),
      srsAgain: l(srsAgain, other.srsAgain),
      srsHard: l(srsHard, other.srsHard),
      srsMedium: l(srsMedium, other.srsMedium),
      srsEasy: l(srsEasy, other.srsEasy),
      mastered: l(mastered, other.mastered),
      learning: l(learning, other.learning),
      reviewDue: l(reviewDue, other.reviewDue),
      streakStart: l(streakStart, other.streakStart),
      streakEnd: l(streakEnd, other.streakEnd),
      success: l(success, other.success),
      danger: l(danger, other.danger),
    );
  }
}

/// `context.appColors` — terse access to the app's design tokens from
/// anywhere, always resolved for the *current* theme (light/dark + accent).
extension AppColorsContext on BuildContext {
  AppColorsExt get appColors => Theme.of(this).extension<AppColorsExt>()!;
}

class AppTheme {
  AppTheme._();

  static ThemeData light(AccentColor accent) => _build(AppColorsExt.light(accent), Brightness.light);
  static ThemeData dark(AccentColor accent) => _build(AppColorsExt.dark(accent), Brightness.dark);

  static ThemeData _build(AppColorsExt colors, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      extensions: [colors],
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.srsAgain,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 28, height: 1.2),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 22, height: 1.25),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15, color: colors.textMuted, letterSpacing: 0.4),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 15, color: colors.textSecondary, height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 13, color: colors.textSecondary, height: 1.5),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: colors.textPrimary,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.textMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary.withValues(alpha: 0.5) : null,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surface,
        hourMinuteColor: colors.surfaceElevated,
        hourMinuteTextColor: colors.textPrimary,
        dayPeriodColor: colors.surfaceElevated,
        dayPeriodTextColor: colors.textSecondary,
        dialBackgroundColor: colors.surfaceElevated,
        dialHandColor: colors.primary,
        dialTextColor: colors.textPrimary,
        entryModeIconColor: colors.textSecondary,
        helpTextStyle: TextStyle(color: colors.textMuted),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: colors.textSecondary),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: colors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    );
  }
}
