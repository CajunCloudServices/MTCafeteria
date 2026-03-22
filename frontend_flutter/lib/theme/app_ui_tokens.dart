import 'package:flutter/material.dart';

/// Shared visual tokens for the app's shells, cards, inputs, and sheets.
///
/// The task flows are the baseline geometry for the rest of the app, so the
/// outer surfaces elsewhere should match those values instead of inventing
/// their own radii.
abstract final class AppUiTokens {
  static const Color shellBorder = Color(0xFFD7E3F2);
  static const Color shellBorderMuted = Color(0xFFD3E0F0);
  static const Color shellShadow = Color(0x12183A63);
  static const Color shellSurface = Colors.white;
  static const Color panelSurface = Color(0xFFF8FBFF);
  static const Color chipSurface = Color(0xFFF5F8FC);
  static const Color chipBorder = Color(0xFFD6E2F0);

  static const double cardRadius = 10;
  static const double buttonRadius = 8;
  static const double inputRadius = 6;
  static const double chipRadius = 6;
  static const double accentRadius = 3;
  static const double sheetRadius = 16;

  static const List<BoxShadow> shellShadowSoft = [
    BoxShadow(color: shellShadow, blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> cardShadowSoft = [
    BoxShadow(color: Color(0x0D183A63), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static RoundedRectangleBorder cardShape() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius));

  static OutlineInputBorder inputBorder([Color color = shellBorder]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: color),
      );
}
