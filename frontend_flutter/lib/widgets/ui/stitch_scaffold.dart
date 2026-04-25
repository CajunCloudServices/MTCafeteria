import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Standardized page scaffold.
///
/// Every Stitch screen:
/// - centers content inside `max-w-md mx-auto` (mobile) / `max-w-7xl` (desktop),
/// - has `bg-surface` ground,
/// - applies `px-6` horizontal padding,
/// - reserves bottom padding for bottom nav and safe-area.
class StitchScaffold extends StatelessWidget {
  const StitchScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNav,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor = StitchColors.surface,
    this.extendBodyBehindAppBar = true,
    this.maxWidth = StitchLayout.mobileMaxWidth,
    this.horizontalPadding = StitchLayout.pagePaddingH,
    this.resizeToAvoidBottomInset = true,
    this.scrollable = false,
    this.bottomSafeArea = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color backgroundColor;
  final bool extendBodyBehindAppBar;
  final double maxWidth;
  final double horizontalPadding;
  final bool resizeToAvoidBottomInset;
  final bool scrollable;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width < StitchLayout.mobileBreakpoint
        ? StitchLayout.pagePaddingHMobile
        : horizontalPadding;

    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: body,
        ),
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: bottomNav != null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: SafeArea(top: false, bottom: bottomSafeArea, child: content),
    );
  }
}
