import 'package:flutter/material.dart';

import 'stitch_tokens.dart';

/// Legacy token shim. The canonical design system is [StitchColors],
/// [StitchRadii], [StitchShadows], and [StitchText] in `stitch_tokens.dart`.
///
/// All historical field names below remain so older widgets keep compiling,
/// but every value now resolves to a Stitch equivalent so the app inherits
/// the redesign without having to touch every legacy call site.
abstract final class AppUiTokens {
  // Surfaces / borders now map to Stitch equivalents.
  static const Color shellBorder = StitchColors.outlineVariant;
  static const Color shellBorderMuted = StitchColors.outlineVariant;
  static const Color shellShadow = Color(0x14051125); // rgba(5,17,37,0.08)
  static const Color shellSurface = StitchColors.surfaceContainerLowest;
  static const Color panelSurface = StitchColors.surfaceContainerLow;
  static const Color chipSurface = StitchColors.surfaceContainerLow;
  static const Color chipBorder = StitchColors.outlineVariant;

  static const double cardRadius = StitchRadii.md; // 8
  static const double buttonRadius = StitchRadii.sm; // 4
  static const double inputRadius = StitchRadii.md; // 8
  static const double chipRadius = StitchRadii.lg; // 12
  static const double accentRadius = StitchRadii.xs; // 2
  static const double sheetRadius = 20; // bottom-sheet specific

  static const List<BoxShadow> shellShadowSoft = StitchShadows.cardSoft;
  static const List<BoxShadow> cardShadowSoft = StitchShadows.subtle;

  static RoundedRectangleBorder cardShape() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius));

  static OutlineInputBorder inputBorder([Color color = shellBorder]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: color),
      );
}
