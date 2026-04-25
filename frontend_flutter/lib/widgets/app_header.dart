import 'package:flutter/material.dart';

import '../theme/stitch_tokens.dart';

double appHeaderToolbarHeight(BuildContext context) =>
    MediaQuery.of(context).size.width < StitchLayout.mobileBreakpoint ? 88 : 72;

double appHeaderMenuIconSize(BuildContext context) =>
    MediaQuery.of(context).size.width < StitchLayout.mobileBreakpoint ? 26 : 24;

/// Canonical page title used by every screen's app bar.
///
/// This is the single source of truth for the page header style, so every
/// page reads identically — same font, weight, size, color — regardless of
/// whether it is a root tab or a sub-view with a back button.
Text buildAppHeaderTitle(BuildContext context, String label) {
  final isMobile =
      MediaQuery.of(context).size.width < StitchLayout.mobileBreakpoint;
  return Text(
    label,
    style: TextStyle(
      fontFamily: StitchFonts.headline,
      fontFamilyFallback: StitchFonts.fallback,
      fontSize: isMobile ? 24 : 26,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: StitchColors.primary,
      height: 1.15,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class AppHeaderMenuButton extends StatelessWidget {
  const AppHeaderMenuButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
  });

  final PopupMenuItemBuilder<String> itemBuilder;
  final PopupMenuItemSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < StitchLayout.mobileBreakpoint;
    return PopupMenuButton<String>(
      padding: EdgeInsets.only(left: 8, right: isMobile ? 12 : 10),
      icon: Icon(
        Icons.menu_rounded,
        size: appHeaderMenuIconSize(context),
        color: StitchColors.primary,
      ),
      onSelected: onSelected,
      itemBuilder: itemBuilder,
    );
  }
}
