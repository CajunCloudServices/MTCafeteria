import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Stitch sticky app header.
///
/// Matches:
/// ```
/// sticky top-0 z-20 backdrop-blur-md bg-[#f8f9fb]/85
/// border-b border-[#edeef0] h-16 px-4 flex items-center justify-between
/// ```
class StitchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StitchAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
    this.showBack = false,
    this.onBack,
    this.elevated = false,
    this.centerTitle = false,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;

  /// Whether to show the hairline divider along the bottom edge.
  final bool elevated;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    StitchLayout.headerHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final resolvedLeading =
        leading ??
        (showBack
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xD9F8F9FB),
            border: Border(
              bottom: BorderSide(
                color: elevated
                    ? StitchColors.hairline
                    : StitchColors.hairline.withValues(alpha: 0.0),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: StitchLayout.headerHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        if (resolvedLeading != null) resolvedLeading,
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: resolvedLeading == null ? 16 : 4,
                              right: actions.isEmpty ? 16 : 4,
                            ),
                            child: Align(
                              alignment: centerTitle
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child:
                                  titleWidget ??
                                  (title == null
                                      ? const SizedBox.shrink()
                                      : Text(
                                          title!,
                                          style: const TextStyle(
                                            fontFamily: StitchFonts.headline,
                                            fontFamilyFallback:
                                                StitchFonts.fallback,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: StitchColors.primary,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                            ),
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A typical header action icon button in Stitch (circle hit-area, primary
/// foreground color).
class StitchAppBarAction extends StatelessWidget {
  const StitchAppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: StitchColors.primary, size: 24),
      onPressed: onPressed,
    );

    if (badgeCount == null || badgeCount == 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: StitchColors.error,
              borderRadius: BorderRadius.circular(StitchRadii.pill),
              border: Border.all(color: StitchColors.surface, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              badgeCount! > 9 ? '9+' : '$badgeCount',
              style: StitchText.eyebrowBold.copyWith(
                color: StitchColors.onError,
                fontSize: 12,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
