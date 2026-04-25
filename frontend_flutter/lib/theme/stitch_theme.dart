import 'package:flutter/material.dart';

import 'stitch_tokens.dart';

/// Builds the single canonical [ThemeData] that mirrors Stitch.
///
/// Any visual surface in the app that reads from Theme (AppBar, Scaffold,
/// Card, Buttons, Inputs, BottomNavigationBar) inherits Stitch values from
/// here without touching the widget tree.
ThemeData buildStitchTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: StitchColors.primary,
    onPrimary: StitchColors.onPrimary,
    primaryContainer: StitchColors.primaryContainer,
    onPrimaryContainer: StitchColors.onPrimaryContainer,
    secondary: StitchColors.secondary,
    onSecondary: StitchColors.onSecondary,
    secondaryContainer: StitchColors.secondaryContainer,
    onSecondaryContainer: StitchColors.onSecondaryContainer,
    tertiary: StitchColors.tertiary,
    onTertiary: StitchColors.onTertiary,
    tertiaryContainer: StitchColors.tertiaryContainer,
    onTertiaryContainer: StitchColors.onTertiaryContainer,
    error: StitchColors.error,
    onError: StitchColors.onError,
    errorContainer: StitchColors.errorContainer,
    onErrorContainer: StitchColors.onErrorContainer,
    surface: StitchColors.surface,
    onSurface: StitchColors.onSurface,
    surfaceContainerLowest: StitchColors.surfaceContainerLowest,
    surfaceContainerLow: StitchColors.surfaceContainerLow,
    surfaceContainer: StitchColors.surfaceContainer,
    surfaceContainerHigh: StitchColors.surfaceContainerHigh,
    surfaceContainerHighest: StitchColors.surfaceContainerHighest,
    onSurfaceVariant: StitchColors.onSurfaceVariant,
    outline: StitchColors.outline,
    outlineVariant: StitchColors.outlineVariant,
    inversePrimary: StitchColors.inversePrimary,
    inverseSurface: StitchColors.inverseSurface,
    onInverseSurface: StitchColors.inverseOnSurface,
    surfaceTint: StitchColors.surfaceTint,
  );

  final textTheme = const TextTheme(
    displayLarge: StitchText.displayXl,
    displayMedium: StitchText.display,
    displaySmall: StitchText.displayEditorial,
    headlineLarge: StitchText.displayEditorial,
    headlineMedium: StitchText.display,
    headlineSmall: StitchText.titleLg,
    titleLarge: StitchText.titleLg,
    titleMedium: StitchText.titleMd,
    titleSmall: StitchText.titleSm,
    bodyLarge: StitchText.bodyLg,
    bodyMedium: StitchText.body,
    bodySmall: StitchText.body,
    labelLarge: StitchText.buttonMd,
    labelMedium: StitchText.bodyStrong,
    labelSmall: StitchText.body,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: StitchColors.surface,
    canvasColor: StitchColors.surface,
    dividerColor: StitchColors.hairline,
    splashColor: StitchColors.primary.withValues(alpha: 0.08),
    highlightColor: StitchColors.primary.withValues(alpha: 0.06),
    fontFamily: StitchFonts.body,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xF7FBFCFD),
      foregroundColor: StitchColors.primary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: StitchFonts.headline,
        fontFamilyFallback: StitchFonts.fallback,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: StitchColors.primary,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: StitchColors.primary, size: 24),
      actionsIconTheme: IconThemeData(color: StitchColors.primary, size: 24),
    ),

    cardTheme: CardThemeData(
      color: StitchColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
      shadowColor: StitchColors.primary.withValues(alpha: 0.12),
    ),

    dividerTheme: const DividerThemeData(
      color: StitchColors.hairline,
      thickness: 1,
      space: 1,
    ),

    iconTheme: const IconThemeData(
      color: StitchColors.onSurfaceVariant,
      size: 24,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StitchColors.surfaceContainerLowest,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      labelStyle: StitchText.fieldLabel,
      floatingLabelStyle: StitchText.fieldLabel.copyWith(
        color: StitchColors.primary,
      ),
      hintStyle: StitchText.body.copyWith(
        color: StitchColors.onSurfaceVariant.withValues(alpha: 0.85),
      ),
      prefixIconColor: StitchColors.onSurfaceVariant,
      suffixIconColor: StitchColors.onSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        borderSide: BorderSide(
          color: StitchColors.outlineVariant.withValues(alpha: 0.9),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        borderSide: BorderSide(
          color: StitchColors.outlineVariant.withValues(alpha: 0.9),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        borderSide: const BorderSide(color: StitchColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        borderSide: const BorderSide(color: StitchColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        borderSide: const BorderSide(color: StitchColors.error, width: 2),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StitchColors.primary,
        foregroundColor: StitchColors.onPrimary,
        minimumSize: const Size(0, StitchLayout.ctaHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
        ),
        textStyle: StitchText.buttonMd,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: StitchColors.primary,
        foregroundColor: StitchColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(0, StitchLayout.ctaHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
        ),
        textStyle: StitchText.buttonMd,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: StitchColors.primary,
        minimumSize: const Size(0, StitchLayout.ctaHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(
          color: StitchColors.outlineVariant.withValues(alpha: 0.9),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
        ),
        textStyle: StitchText.buttonMd.copyWith(color: StitchColors.primary),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: StitchColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
        ),
        textStyle: StitchText.buttonSm.copyWith(color: StitchColors.primary),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.xs),
      ),
      side: BorderSide(color: StitchColors.outline, width: 2),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return StitchColors.primary;
        return StitchColors.surfaceContainerLowest;
      }),
      checkColor: WidgetStateProperty.all(StitchColors.onPrimary),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return StitchColors.primary;
        return StitchColors.outline;
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return StitchColors.onPrimary;
        }
        return StitchColors.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return StitchColors.primary;
        }
          return StitchColors.surfaceContainerHigh;
      }),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: Colors.transparent,
      disabledColor: Colors.transparent,
      labelStyle: StitchText.bodyStrong.copyWith(
        color: StitchColors.onSurfaceVariant,
      ),
      secondaryLabelStyle: StitchText.bodyStrong.copyWith(
        color: StitchColors.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(),
      brightness: Brightness.light,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: StitchColors.primary,
      linearTrackColor: StitchColors.surfaceContainerHigh,
      circularTrackColor: StitchColors.surfaceContainerHigh,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: StitchColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
      titleTextStyle: StitchText.titleLg,
      contentTextStyle: StitchText.bodyLg.copyWith(
        color: StitchColors.onSurface,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: StitchColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: StitchColors.outline,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(StitchRadii.lg)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: StitchColors.inverseSurface,
      contentTextStyle: StitchText.bodyStrong.copyWith(
        color: StitchColors.inverseOnSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: StitchColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
      textStyle: StitchText.bodyStrong,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: StitchColors.surface,
      indicatorColor: StitchColors.primary,
      surfaceTintColor: Colors.transparent,
      height: 72,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return StitchText.navLabel.copyWith(
          color: isSelected ? StitchColors.onPrimary : StitchColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? StitchColors.onPrimary : StitchColors.onSurfaceVariant,
          size: 24,
        );
      }),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: StitchColors.surface,
      selectedItemColor: StitchColors.primary,
      unselectedItemColor: StitchColors.onSurfaceVariant,
      selectedLabelStyle: StitchText.navLabel,
      unselectedLabelStyle: StitchText.navLabel,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: StitchColors.onSurfaceVariant,
      textColor: StitchColors.onSurface,
      tileColor: StitchColors.surfaceContainerLowest,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: StitchColors.primary,
      unselectedLabelColor: StitchColors.onSurfaceVariant,
      labelStyle: StitchText.buttonSm,
      unselectedLabelStyle: StitchText.buttonSm,
      indicatorColor: StitchColors.primary,
      dividerColor: StitchColors.hairline,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: StitchColors.inverseSurface,
        borderRadius: BorderRadius.circular(StitchRadii.sm),
      ),
      textStyle: StitchText.caption.copyWith(
        color: StitchColors.inverseOnSurface,
      ),
    ),
  );
}
