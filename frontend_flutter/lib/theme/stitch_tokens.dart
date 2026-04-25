import 'package:flutter/material.dart';

/// Canonical Stitch design tokens for MTC Dining.
///
/// All values here are copied 1:1 from the Stitch Tailwind configurations
/// shipped with the redesign zip (see
/// `stitch_designs/stitch_mtc_cafeteria_ops_redesign/*/code.html`). Every UI
/// surface in the app should read from this file instead of hard-coding hex
/// values, radii, shadows, or text styles.
abstract final class StitchColors {
  // Primary scale (deep navy brand).
  static const Color primary = Color(0xFF051125);
  static const Color primaryContainer = Color(0xFF1B263B);
  static const Color primaryFixed = Color(0xFFD7E2FF);
  static const Color primaryFixedDim = Color(0xFFBBC6E2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF828DA7);
  static const Color onPrimaryFixed = Color(0xFF101B30);
  static const Color onPrimaryFixedVariant = Color(0xFF3C475D);

  // Secondary scale (soft blue).
  static const Color secondary = Color(0xFF506071);
  static const Color secondaryContainer = Color(0xFFD3E4F9);
  static const Color secondaryFixed = Color(0xFFD3E4F9);
  static const Color secondaryFixedDim = Color(0xFFB7C8DC);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF566677);
  static const Color onSecondaryFixed = Color(0xFF0C1D2B);
  static const Color onSecondaryFixedVariant = Color(0xFF384858);

  // Tertiary scale (pale cyan accent).
  static const Color tertiary = Color(0xFF00141A);
  static const Color tertiaryContainer = Color(0xFF002A34);
  static const Color tertiaryFixed = Color(0xFFB2EBFF);
  static const Color tertiaryFixedDim = Color(0xFF8BD1E8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF4F96AC);
  static const Color onTertiaryFixed = Color(0xFF001F27);
  static const Color onTertiaryFixedVariant = Color(0xFF004E5F);

  // Surfaces.
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFD3D9E0);
  static const Color surfaceTint = Color(0xFF545E76);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF30343A);
  static const Color onBackground = Color(0xFF191C1E);
  static const Color surfaceVariant = Color(0xFFE4E8ED);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F5F8);
  static const Color surfaceContainer = Color(0xFFEDEFF3);
  static const Color surfaceContainerHigh = Color(0xFFE5E8ED);
  static const Color surfaceContainerHighest = Color(0xFFDDE2E8);

  // Outlines.
  static const Color outline = Color(0xFF636D79);
  static const Color outlineVariant = Color(0xFFAAB4C0);

  // Feedback.
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Inverse.
  static const Color inversePrimary = Color(0xFFBBC6E2);
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F3);

  // Utility accents used by announcements (derived from the Stitch "error"
  // and "tertiary-fixed-dim" families for reminder/special-event ribbons).
  static const Color reminderAccent = Color(0xFF8C5B00);
  static const Color specialEventAccent = Color(0xFF8C1D40);
  static const Color announcementAccent = primary;

  // Hairline divider used in header/app-bar underlines (#edeef0 1px).
  static const Color hairline = Color(0xFFDFE4EA);
}

/// Stitch border-radius scale. Stitch overrides Tailwind's defaults:
/// `rounded` = 2px, `rounded-lg` = 4px, `rounded-xl` = 8px,
/// `rounded-full` = 12px (true pills use 9999).
abstract final class StitchRadii {
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 9999;
}

/// Stitch spacing scale in px. Tailwind `p-1..p-12`.
abstract final class StitchSpacing {
  static const double xs = 4; // 0.25rem
  static const double sm = 8; // 0.5rem
  static const double md = 12; // 0.75rem
  static const double lg = 16; // 1rem
  static const double xl = 20; // 1.25rem
  static const double xl2 = 24; // 1.5rem
  static const double xl3 = 32; // 2rem
  static const double xl4 = 40; // 2.5rem
  static const double xl5 = 48; // 3rem
}

/// Stitch shadow presets. Alpha values are applied exactly as Tailwind's
/// `rgba(5,17,37, x)`.
abstract final class StitchShadows {
  /// `shadow-[0_12px_32px_-8px_rgba(5,17,37,0.08)]` — the dominant soft card
  /// shadow used across the app.
  static const List<BoxShadow> cardSoft = [
    BoxShadow(
      color: Color(0x1E051125), // rgba(5,17,37,0.12)
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  /// `shadow-[0_12px_32px_-8px_rgba(5,17,37,0.15)]` — heavier CTA shadow.
  static const List<BoxShadow> ctaStrong = [
    BoxShadow(
      color: Color(0x26051125), // rgba(5,17,37,0.15)
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  /// `shadow-[0_4px_16px_-4px_rgba(5,17,37,0.04)]` — subtle secondary
  /// surface elevation.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x14051125), // rgba(5,17,37,0.08)
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  /// `shadow-[0_2px_8px_-2px_rgba(5,17,37,0.04)]` — form-card elevation.
  static const List<BoxShadow> form = [
    BoxShadow(
      color: Color(0x14051125),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  /// Inverted shadow for bottom navigation bars.
  /// `shadow-[0_-12px_32px_-8px_rgba(5,17,37,0.08)]`
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14051125),
      blurRadius: 32,
      offset: Offset(0, -12),
      spreadRadius: -8,
    ),
  ];
}

/// Canonical Stitch type families. The actual font loading is wired up via
/// `web/index.html` (Google Fonts CSS) so Flutter can use these family names
/// directly with `TextStyle(fontFamily: ...)`.
abstract final class StitchFonts {
  static const String headline = 'Manrope';
  static const String body = 'Inter';
  static const String label = 'Inter';

  /// Fallback stack used so analyses without Google Fonts do not crash.
  static const List<String> fallback = [
    'Segoe UI',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];
}

/// Opinionated Stitch text styles. Every class matches a pattern observed in
/// the Stitch HTML:
/// - `font-headline font-extrabold text-3xl tracking-tight text-primary`
/// - `font-label text-xs font-semibold tracking-widest uppercase ...`
/// - etc.
///
/// Use these directly (`style: StitchText.sectionTitle`) or via the global
/// `TextTheme` built in `stitch_theme.dart`.
abstract final class StitchText {
  // Display / page titles.
  static const TextStyle displayXl = TextStyle(
    // font-headline text-4xl font-extrabold tracking-tight
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.1,
    color: StitchColors.primary,
  );

  static const TextStyle display = TextStyle(
    // font-headline text-3xl font-extrabold tracking-tight
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.1,
    color: StitchColors.primary,
  );

  /// 32px extrabold headline used by "Good Morning" / "Alex Mercer" blocks.
  static const TextStyle displayEditorial = TextStyle(
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.05,
    color: StitchColors.primary,
  );

  // Section / card titles.
  static const TextStyle titleLg = TextStyle(
    // font-headline font-bold text-xl tracking-tight text-primary
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
    color: StitchColors.primary,
  );

  static const TextStyle titleMd = TextStyle(
    // font-headline font-bold text-lg text-primary tracking-tight
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
    color: StitchColors.primary,
  );

  static const TextStyle titleSm = TextStyle(
    // font-headline font-bold text-base / text-sm
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: StitchColors.primary,
  );

  static const TextStyle titleXs = TextStyle(
    // Hub-card icon-tile titles: font-headline font-bold text-sm text-on-surface
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: StitchColors.onSurface,
    height: 1.25,
  );

  // Eyebrow / uppercase label used for section eyebrows and micro-chips.
  static const TextStyle eyebrow = TextStyle(
    // font-label text-xs font-semibold tracking-widest uppercase
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    color: StitchColors.onSurface,
    height: 1.3,
  );

  static const TextStyle eyebrowSmall = TextStyle(
    // font-label text-[11px] uppercase tracking-[0.05em] font-semibold
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.35,
    color: StitchColors.onSurface,
    height: 1.3,
  );

  static const TextStyle eyebrowBold = TextStyle(
    // Status pill: font-label text-[10px] uppercase tracking-widest font-bold
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    color: StitchColors.onSurface,
    height: 1.2,
  );

  // Body.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: StitchFonts.body,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: StitchColors.onSurface,
  );

  static const TextStyle body = TextStyle(
    // font-body text-sm text-on-surface-variant leading-relaxed
    fontFamily: StitchFonts.body,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: StitchColors.onSurface,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: StitchFonts.body,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: StitchColors.onSurface,
  );

  static const TextStyle caption = TextStyle(
    // font-body text-xs text-on-surface-variant
    fontFamily: StitchFonts.body,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: StitchColors.onSurface,
  );

  // Buttons.
  static const TextStyle buttonLg = TextStyle(
    // font-headline font-bold text-lg
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: StitchColors.onPrimary,
  );

  static const TextStyle buttonMd = TextStyle(
    // font-headline font-semibold text-base
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: StitchColors.onPrimary,
  );

  static const TextStyle buttonSm = TextStyle(
    // font-label text-sm font-semibold
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // Bottom-nav label.
  static const TextStyle navLabel = TextStyle(
    // font-['Inter'] font-medium text-[11px] tracking-widest uppercase
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.2,
  );

  // Metric / big-number styles (profile points, stat cards).
  static const TextStyle metric = TextStyle(
    // font-headline font-extrabold text-[32px] text-primary leading-none
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.0,
    color: StitchColors.primary,
  );

  static const TextStyle metricSm = TextStyle(
    // font-headline font-bold text-3xl text-primary
    fontFamily: StitchFonts.headline,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: StitchColors.primary,
  );

  // Field label (ghost input): font-label text-xs font-semibold uppercase
  // tracking-wide text-on-surface-variant.
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: StitchFonts.label,
    fontFamilyFallback: StitchFonts.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: StitchColors.onSurface,
    height: 1.3,
  );
}

/// Primary CTA gradient (from-primary to-primary-container) applied as a
/// `bg-gradient-to-r` (left → right) consistently across Stitch CTAs.
const Gradient stitchPrimaryGradient = LinearGradient(
  colors: [StitchColors.primary, StitchColors.primaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// Mobile content is constrained to `max-w-md` (448px). Desktop opens up
/// to `max-w-7xl` (1280px).
abstract final class StitchLayout {
  static const double mobileMaxWidth = 448;
  static const double desktopMaxWidth = 1280;
  static const double mobileBreakpoint = 760;
  static const double headerHeight = 64; // h-16
  static const double bottomNavHeight = 76; // py-3 + pb-8/safe
  static const double ctaHeight = 48; // h-12
  static const double ctaHeightLg = 56; // min-h-[56px]
  static const double pagePaddingH = 24; // px-6
  static const double pagePaddingHMobile = 16; // px-4
}
