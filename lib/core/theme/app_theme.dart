import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// "Armário Aberto" identity theme — see `docs/DESIGN.md`.
abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final surfaceElevated =
        isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    // Heading font (Bitter) + body/UI font (Manrope) — dynamically fetched
    // via google_fonts, same delivery mechanism the app already used for
    // Nunito (docs/DESIGN.md §2: deliberately kept, not switched to bundled
    // static assets).
    final headingTextTheme = GoogleFonts.bitterTextTheme();
    final bodyTextTheme = GoogleFonts.manropeTextTheme();

    // Type scale → Flutter TextTheme (docs/DESIGN.md §2). Sizes/line-heights
    // already match Material 3's default TextTheme scale; only the font
    // family per slot and a handful of weights differ from M3 defaults, so
    // weights are baked in here once instead of every call site doing
    // `.copyWith(fontWeight: ...)`.
    final baseTextTheme = bodyTextTheme.copyWith(
      displayLarge: headingTextTheme.displayLarge,
      displayMedium: headingTextTheme.displayMedium,
      displaySmall:
          headingTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge: headingTextTheme.headlineLarge
          ?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: headingTextTheme.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: headingTextTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700),
      titleLarge:
          headingTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium:
          bodyTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall:
          bodyTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge:
          bodyTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium:
          bodyTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      labelSmall:
          bodyTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
    );

    final textTheme = baseTextTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // §3 background/surface role correction: the scaffold canvas is the
      // "recessed" role (surfaceContainerLowest, wired to the `background`
      // token below), cards/rows sit in the plain `surface` slot.
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: divider, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          // Buttons deliberately keep M3's default pill/stadium shape —
          // docs/DESIGN.md §3 explicitly says not to square these off too.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          side: BorderSide(color: colorScheme.primary),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // §4.4: background = `surface` token, distinct fixed chrome panel.
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceElevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(3),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.onPrimaryLight,
    primaryContainer: AppColors.primaryContainerLight,
    onPrimaryContainer: AppColors.onPrimaryContainerLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.onSecondaryLight,
    secondaryContainer: AppColors.secondaryContainerLight,
    onSecondaryContainer: AppColors.onSecondaryContainerLight,
    tertiary: AppColors.tertiaryLight,
    onTertiary: AppColors.onTertiaryLight,
    tertiaryContainer: AppColors.tertiaryContainerLight,
    onTertiaryContainer: AppColors.onTertiaryContainerLight,
    error: AppColors.errorLight,
    onError: AppColors.onErrorLight,
    errorContainer: AppColors.errorContainerLight,
    onErrorContainer: AppColors.onErrorContainerLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.inkPrimaryLight,
    surfaceContainerLowest: AppColors.backgroundLight,
    surfaceContainerLow: Color(0xFFF3F5F5),
    surfaceContainer: Color(0xFFEBEFEF),
    surfaceContainerHigh: Color(0xFFE3E8E8),
    surfaceContainerHighest: Color(0xFFDCE2E2),
    onSurfaceVariant: AppColors.inkSecondaryLight,
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.dividerLight,
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E3438),
    onInverseSurface: Color(0xFFEEF1F1),
    inversePrimary: AppColors.primaryDark,
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: AppColors.onPrimaryContainerDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    secondaryContainer: AppColors.secondaryContainerDark,
    onSecondaryContainer: AppColors.onSecondaryContainerDark,
    tertiary: AppColors.tertiaryDark,
    onTertiary: AppColors.onTertiaryDark,
    tertiaryContainer: AppColors.tertiaryContainerDark,
    onTertiaryContainer: AppColors.onTertiaryContainerDark,
    error: AppColors.errorDark,
    onError: AppColors.onErrorDark,
    errorContainer: AppColors.errorContainerDark,
    onErrorContainer: AppColors.onErrorContainerDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.inkPrimaryDark,
    surfaceContainerLowest: AppColors.backgroundDark,
    surfaceContainerLow: Color(0xFF171C21),
    surfaceContainer: Color(0xFF1F252B),
    surfaceContainerHigh: Color(0xFF262D33),
    surfaceContainerHighest: Color(0xFF313940),
    onSurfaceVariant: AppColors.inkSecondaryDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.dividerDark,
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEDEFF1),
    onInverseSurface: Color(0xFF1B2024),
    inversePrimary: AppColors.primaryLight,
  );
}
