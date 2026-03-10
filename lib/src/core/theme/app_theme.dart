import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 240);
}

class AppRadii {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(20);
}

class AppCorners {
  static const sm = BorderRadius.all(AppRadii.sm);
  static const md = BorderRadius.all(AppRadii.md);
  static const lg = BorderRadius.all(AppRadii.lg);
  static const xl = BorderRadius.all(AppRadii.xl);
}

class AppIconSize {
  static const xs = 16.0;
  static const sm = 18.0;
  static const md = 22.0;
  static const lg = 28.0;
}

class _AppColorTokens {
  static const darkPrimary = Color(0xFFFFD700);
  static const darkPrimaryContainer = Color(0xFF5C4700);
  static const darkSecondary = Color(0xFF81C784);
  static const darkSecondaryContainer = Color(0xFF243428);
  static const darkTertiary = Color(0xFF90A4AE);
  static const darkTertiaryContainer = Color(0xFF26343B);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceLow = Color(0xFF181818);
  static const darkSurfaceHigh = Color(0xFF212121);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkOnSurfaceMuted = Color(0xFFB0BEC5);
  static const darkOutline = Color(0xFF3F4548);
  static const darkOutlineVariant = Color(0xFF2A2E31);
  static const darkError = Color(0xFFEF5350);
  static const darkErrorContainer = Color(0xFF5A1D1C);

  static const lightPrimary = Color(0xFF8D6900);
  static const lightPrimaryContainer = Color(0xFFFFE39A);
  static const lightSecondary = Color(0xFF5B5F68);
  static const lightSecondaryContainer = Color(0xFFE8ECF3);
  static const lightTertiary = Color(0xFF246C64);
  static const lightTertiaryContainer = Color(0xFFAEE6DE);
  static const lightBackground = Color(0xFFF6F7FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceLow = Color(0xFFF1F3F7);
  static const lightSurfaceHigh = Color(0xFFE8ECF3);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF14171D);
  static const lightOnSurfaceMuted = Color(0xFF5F6672);
  static const lightOutline = Color(0xFFB8C0CD);
  static const lightOutlineVariant = Color(0xFFDCE1EA);
  static const lightError = Color(0xFFB3261E);
  static const lightErrorContainer = Color(0xFFF9DEDC);

  static const googlePrimary = Color(0xFF1A73E8);
  static const googlePrimaryContainer = Color(0xFFD3E3FD);
  static const googleSecondary = Color(0xFFEA4335);
  static const googleSecondaryContainer = Color(0xFFFAD2CF);
  static const googleTertiary = Color(0xFF34A853);
  static const googleTertiaryContainer = Color(0xFFCEEAD6);
  static const googleBackground = Color(0xFFF8F9FA);
  static const googleSurface = Color(0xFFFFFFFF);
  static const googleSurfaceLow = Color(0xFFF1F3F4);
  static const googleSurfaceHigh = Color(0xFFF6F8FC);
  static const googleOnPrimary = Color(0xFFFFFFFF);
  static const googleOnSurface = Color(0xFF1F1F1F);
  static const googleOnSurfaceMuted = Color(0xFF5F6368);
  static const googleOutline = Color(0xFFDADCE0);
  static const googleOutlineVariant = Color(0xFFE8EAED);
  static const googleError = Color(0xFFD93025);
  static const googleErrorContainer = Color(0xFFFCE8E6);
}

enum AppThemePreset { goldDark, goldLight, googleClean }

class AppThemeBundle {
  const AppThemeBundle({
    required this.theme,
    required this.darkTheme,
    required this.mode,
  });

  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode mode;
}

class AppThemePresetMeta {
  const AppThemePresetMeta({
    required this.title,
    required this.subtitle,
    required this.previewColors,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> previewColors;
  final IconData icon;
}

class AppTheme {
  static ThemeData get dynamicDarkTheme => _buildDynamicDarkTheme();
  static ThemeData get dynamicLightTheme => _buildDynamicLightTheme();
  static ThemeData get googleLightTheme => _buildGoogleLightTheme();
  static ThemeData get darkTheme => dynamicDarkTheme;
  static ThemeData get lightTheme => dynamicLightTheme;

  static ThemeData dark() => darkTheme;
  static ThemeData light() => lightTheme;

  static const defaultPreset = AppThemePreset.goldDark;
  static List<AppThemePreset> get presets => AppThemePreset.values;

  static AppThemeBundle bundleFor(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.goldDark:
        return AppThemeBundle(
          theme: dynamicDarkTheme,
          darkTheme: dynamicDarkTheme,
          mode: ThemeMode.dark,
        );
      case AppThemePreset.goldLight:
        return AppThemeBundle(
          theme: dynamicLightTheme,
          darkTheme: dynamicLightTheme,
          mode: ThemeMode.light,
        );
      case AppThemePreset.googleClean:
        return AppThemeBundle(
          theme: googleLightTheme,
          darkTheme: googleLightTheme,
          mode: ThemeMode.light,
        );
    }
  }

  static AppThemePresetMeta metaFor(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.goldDark:
        return const AppThemePresetMeta(
          title: 'Gold Dark',
          subtitle: 'Hitam pekat dengan aksen emas.',
          previewColors: [
            _AppColorTokens.darkPrimary,
            _AppColorTokens.darkSecondary,
            _AppColorTokens.darkTertiary,
          ],
          icon: Icons.dark_mode_outlined,
        );
      case AppThemePreset.goldLight:
        return const AppThemePresetMeta(
          title: 'Gold Light',
          subtitle: 'Versi terang dari tema emas.',
          previewColors: [
            _AppColorTokens.lightPrimary,
            Color(0xFFD6B04B),
            Color(0xFF95A6B0),
          ],
          icon: Icons.light_mode_outlined,
        );
      case AppThemePreset.googleClean:
        return const AppThemePresetMeta(
          title: 'Google Clean',
          subtitle: 'Putih bersih dengan dot aksen warna.',
          previewColors: [
            _AppColorTokens.googlePrimary,
            _AppColorTokens.googleSecondary,
            _AppColorTokens.googleTertiary,
          ],
          icon: Icons.apps_rounded,
        );
    }
  }

  static ButtonStyle destructiveTextButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final baseStyle = theme.textButtonTheme.style;

    final destructiveStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.error,
          iconColor: colorScheme.error,
          iconSize: AppIconSize.sm,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.error.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.error.withValues(alpha: 0.10);
            }
            if (states.contains(WidgetState.focused)) {
              return colorScheme.error.withValues(alpha: 0.12);
            }
            return null;
          }),
        );

    return baseStyle?.merge(destructiveStyle) ?? destructiveStyle;
  }

  static ThemeData _buildDynamicDarkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _AppColorTokens.darkPrimary,
      onPrimary: _AppColorTokens.darkOnPrimary,
      primaryContainer: _AppColorTokens.darkPrimaryContainer,
      onPrimaryContainer: Color(0xFFFFF2B5),
      secondary: _AppColorTokens.darkSecondary,
      onSecondary: Color(0xFF091209),
      secondaryContainer: _AppColorTokens.darkSecondaryContainer,
      onSecondaryContainer: Color(0xFFD9F0DA),
      tertiary: _AppColorTokens.darkTertiary,
      onTertiary: Color(0xFF0E1417),
      tertiaryContainer: _AppColorTokens.darkTertiaryContainer,
      onTertiaryContainer: Color(0xFFD6E4EA),
      error: _AppColorTokens.darkError,
      onError: Colors.white,
      errorContainer: _AppColorTokens.darkErrorContainer,
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _AppColorTokens.darkSurface,
      onSurface: _AppColorTokens.darkOnSurface,
      onSurfaceVariant: _AppColorTokens.darkOnSurfaceMuted,
      outline: _AppColorTokens.darkOutline,
      outlineVariant: _AppColorTokens.darkOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE7E0D2),
      onInverseSurface: Color(0xFF1A1A1A),
      inversePrimary: Color(0xFF8F7700),
      surfaceDim: Color(0xFF171717),
      surfaceBright: Color(0xFF2A2A2A),
      surfaceContainerLowest: Color(0xFF111111),
      surfaceContainerLow: _AppColorTokens.darkSurfaceLow,
      surfaceContainer: _AppColorTokens.darkSurface,
      surfaceContainerHigh: _AppColorTokens.darkSurfaceHigh,
      surfaceContainerHighest: Color(0xFF262626),
    );

    final textTheme = _buildTextTheme(
      brightness: Brightness.dark,
      defaultColor: _AppColorTokens.darkOnSurface,
      mutedColor: _AppColorTokens.darkOnSurfaceMuted,
      emphasisColor: _AppColorTokens.darkPrimary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _AppColorTokens.darkBackground,
      appBarBackgroundColor: _AppColorTokens.darkBackground,
      appBarForegroundColor: _AppColorTokens.darkPrimary,
      inputFillColor: const Color(0xFF1A1A1A),
      cardElevation: 4,
      cardBorderRadius: AppCorners.lg,
      cardBorderColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.16),
        colorScheme.outlineVariant,
      ),
      iconColor: colorScheme.tertiary,
      iconSize: AppIconSize.md,
      inputContentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
    );
  }

  static ThemeData _buildDynamicLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _AppColorTokens.lightPrimary,
      onPrimary: _AppColorTokens.lightOnPrimary,
      primaryContainer: _AppColorTokens.lightPrimaryContainer,
      onPrimaryContainer: Color(0xFF2A1E00),
      secondary: _AppColorTokens.lightSecondary,
      onSecondary: _AppColorTokens.lightOnPrimary,
      secondaryContainer: _AppColorTokens.lightSecondaryContainer,
      onSecondaryContainer: _AppColorTokens.lightOnSurface,
      tertiary: _AppColorTokens.lightTertiary,
      onTertiary: _AppColorTokens.lightOnPrimary,
      tertiaryContainer: _AppColorTokens.lightTertiaryContainer,
      onTertiaryContainer: _AppColorTokens.lightOnSurface,
      error: _AppColorTokens.lightError,
      onError: Colors.white,
      errorContainer: _AppColorTokens.lightErrorContainer,
      onErrorContainer: Color(0xFF410E0B),
      surface: _AppColorTokens.lightSurface,
      onSurface: _AppColorTokens.lightOnSurface,
      onSurfaceVariant: _AppColorTokens.lightOnSurfaceMuted,
      outline: _AppColorTokens.lightOutline,
      outlineVariant: _AppColorTokens.lightOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF242A34),
      onInverseSurface: Color(0xFFF7F8FA),
      inversePrimary: Color(0xFFF5CB5A),
      surfaceDim: Color(0xFFE9ECF2),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: _AppColorTokens.lightSurfaceLow,
      surfaceContainer: _AppColorTokens.lightSurface,
      surfaceContainerHigh: _AppColorTokens.lightSurfaceHigh,
      surfaceContainerHighest: Color(0xFFDCE2EC),
    );

    final textTheme = _buildTextTheme(
      brightness: Brightness.light,
      defaultColor: _AppColorTokens.lightOnSurface,
      mutedColor: _AppColorTokens.lightOnSurfaceMuted,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _AppColorTokens.lightBackground,
      appBarBackgroundColor: _AppColorTokens.lightSurface,
      appBarForegroundColor: _AppColorTokens.lightOnSurface,
      inputFillColor: const Color(0xFFF4F4F4),
      cardBorderColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.12),
        colorScheme.outlineVariant,
      ),
    );
  }

  static ThemeData _buildGoogleLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _AppColorTokens.googlePrimary,
      onPrimary: _AppColorTokens.googleOnPrimary,
      primaryContainer: _AppColorTokens.googlePrimaryContainer,
      onPrimaryContainer: Color(0xFF0B1F42),
      secondary: _AppColorTokens.googleSecondary,
      onSecondary: Colors.white,
      secondaryContainer: _AppColorTokens.googleSecondaryContainer,
      onSecondaryContainer: Color(0xFF410002),
      tertiary: _AppColorTokens.googleTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: _AppColorTokens.googleTertiaryContainer,
      onTertiaryContainer: Color(0xFF072711),
      error: _AppColorTokens.googleError,
      onError: Colors.white,
      errorContainer: _AppColorTokens.googleErrorContainer,
      onErrorContainer: Color(0xFF410E0B),
      surface: _AppColorTokens.googleSurface,
      onSurface: _AppColorTokens.googleOnSurface,
      onSurfaceVariant: _AppColorTokens.googleOnSurfaceMuted,
      outline: _AppColorTokens.googleOutline,
      outlineVariant: _AppColorTokens.googleOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF303134),
      onInverseSurface: Color(0xFFF8F9FA),
      inversePrimary: Color(0xFFA8C7FA),
      surfaceDim: Color(0xFFEFF1F3),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: _AppColorTokens.googleSurfaceLow,
      surfaceContainer: _AppColorTokens.googleSurface,
      surfaceContainerHigh: _AppColorTokens.googleSurfaceHigh,
      surfaceContainerHighest: Color(0xFFF1F3F4),
    );

    final textTheme = _buildTextTheme(
      brightness: Brightness.light,
      defaultColor: _AppColorTokens.googleOnSurface,
      mutedColor: _AppColorTokens.googleOnSurfaceMuted,
      emphasisColor: _AppColorTokens.googlePrimary,
      baseTextThemeFactory: (base) => GoogleFonts.robotoTextTheme(base),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _AppColorTokens.googleBackground,
      appBarBackgroundColor: _AppColorTokens.googleSurface,
      appBarForegroundColor: _AppColorTokens.googleOnSurface,
      inputFillColor: const Color(0xFFF8FAFD),
      cardElevation: 1.5,
      cardBorderRadius: AppCorners.lg,
      cardBorderColor: colorScheme.outlineVariant,
      iconColor: colorScheme.primary,
      iconSize: AppIconSize.md,
      inputContentPadding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
      prefixIconConstraints: const BoxConstraints(minWidth: 54, minHeight: 54),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackgroundColor,
    required Color appBarBackgroundColor,
    required Color appBarForegroundColor,
    required Color inputFillColor,
    double cardElevation = 0,
    BorderRadius cardBorderRadius = AppCorners.md,
    Color? cardBorderColor,
    Color? iconColor,
    double iconSize = AppIconSize.sm,
    EdgeInsetsGeometry inputContentPadding = const EdgeInsets.fromLTRB(
      14,
      22,
      14,
      14,
    ),
    BoxConstraints? prefixIconConstraints,
  }) {
    final idleBorder = OutlineInputBorder(
      borderRadius: AppCorners.sm,
      borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: AppCorners.sm,
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      canvasColor: colorScheme.surfaceContainerHigh,
      textTheme: textTheme,
      iconTheme: IconThemeData(
        color: iconColor ?? colorScheme.onSurfaceVariant,
        size: iconSize,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: appBarForegroundColor,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: appBarForegroundColor,
          size: AppIconSize.md,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          iconColor: colorScheme.primary,
          iconSize: AppIconSize.sm,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: cardElevation,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: BorderSide(
            color: cardBorderColor ?? colorScheme.outlineVariant,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: BorderSide(
            color: cardBorderColor ?? colorScheme.outlineVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        contentPadding: inputContentPadding,
        prefixIconConstraints: prefixIconConstraints,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.1,
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: colorScheme.tertiary,
        suffixIconColor: colorScheme.tertiary,
        border: idleBorder,
        enabledBorder: idleBorder,
        focusedBorder: focusedBorder,
        errorBorder: idleBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.1),
        ),
        focusedErrorBorder: focusedBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.3),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHigh,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppCorners.sm),
          ),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHigh,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.black),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppCorners.sm),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppCorners.sm),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceContainerHigh,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: AppCorners.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.9),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: AppRadii.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.18),
          colorScheme.surfaceContainerHighest,
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: selected ? 24 : 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required Color defaultColor,
    required Color mutedColor,
    Color? emphasisColor,
    TextTheme Function(TextTheme base)? baseTextThemeFactory,
  }) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    final foundationTextTheme =
        baseTextThemeFactory?.call(base) ?? GoogleFonts.interTextTheme(base);
    final emphasis = emphasisColor ?? defaultColor;

    return foundationTextTheme.copyWith(
      displayLarge: foundationTextTheme.displayLarge?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: foundationTextTheme.displayMedium?.copyWith(
        color: emphasis,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      displaySmall: foundationTextTheme.displaySmall?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: foundationTextTheme.headlineLarge?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: foundationTextTheme.headlineMedium?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: foundationTextTheme.headlineSmall?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: foundationTextTheme.titleLarge?.copyWith(
        color: emphasis,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: foundationTextTheme.titleMedium?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: foundationTextTheme.titleSmall?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: foundationTextTheme.bodyLarge?.copyWith(
        color: defaultColor,
        height: 1.45,
      ),
      bodyMedium: foundationTextTheme.bodyMedium?.copyWith(
        color: defaultColor,
        height: 1.45,
      ),
      bodySmall: foundationTextTheme.bodySmall?.copyWith(
        color: mutedColor,
        height: 1.4,
      ),
      labelLarge: foundationTextTheme.labelLarge?.copyWith(
        color: defaultColor,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: foundationTextTheme.labelMedium?.copyWith(
        color: mutedColor,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: foundationTextTheme.labelSmall?.copyWith(
        color: mutedColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
