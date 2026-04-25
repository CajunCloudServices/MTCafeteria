import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Stitch surface variant. Maps to the different `bg-surface-container-*`
/// backgrounds observed in the designs.
enum StitchSurface { lowest, low, base, high, highest }

Color _surfaceColor(StitchSurface s) {
  switch (s) {
    case StitchSurface.lowest:
      return StitchColors.surfaceContainerLowest;
    case StitchSurface.low:
      return StitchColors.surfaceContainerLow;
    case StitchSurface.base:
      return StitchColors.surfaceContainer;
    case StitchSurface.high:
      return StitchColors.surfaceContainerHigh;
    case StitchSurface.highest:
      return StitchColors.surfaceContainerHighest;
  }
}

Color _defaultBorderColor(StitchSurface s) {
  switch (s) {
    case StitchSurface.lowest:
      return StitchColors.outlineVariant.withValues(alpha: 0.92);
    case StitchSurface.low:
      return StitchColors.outlineVariant.withValues(alpha: 0.82);
    case StitchSurface.base:
    case StitchSurface.high:
    case StitchSurface.highest:
      return StitchColors.outlineVariant.withValues(alpha: 0.72);
  }
}

/// Stitch shadow preset for card surfaces.
enum StitchCardElevation { none, subtle, card, strong }

List<BoxShadow> _shadowFor(StitchCardElevation e) {
  switch (e) {
    case StitchCardElevation.none:
      return const [];
    case StitchCardElevation.subtle:
      return StitchShadows.subtle;
    case StitchCardElevation.card:
      return StitchShadows.cardSoft;
    case StitchCardElevation.strong:
      return StitchShadows.ctaStrong;
  }
}

/// Generic Stitch card / surface panel.
///
/// Matches:
/// `bg-surface-container-lowest rounded-xl p-6 shadow-[0_12px_32px_-8px_rgba(5,17,37,0.08)]`.
class StitchCard extends StatelessWidget {
  const StitchCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(StitchSpacing.xl2),
    this.surface = StitchSurface.lowest,
    this.elevation = StitchCardElevation.card,
    this.radius = StitchRadii.md,
    this.ring = false,
    this.ringColor,
    this.accentBarColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final StitchSurface surface;
  final StitchCardElevation elevation;
  final double radius;
  final bool ring;
  final Color? ringColor;

  /// Optional left accent ribbon (absolute-positioned 6px bar from Stitch
  /// priority announcement cards).
  final Color? accentBarColor;

  final VoidCallback? onTap;
  final Clip clipBehavior;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bg = _surfaceColor(surface);
    final shadow = _shadowFor(elevation);

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: ring
            ? (ringColor ??
                  StitchColors.outlineVariant.withValues(alpha: 0.8))
            : _defaultBorderColor(surface),
        width: ring ? 1.1 : 1,
      ),
      boxShadow: shadow,
    );

    Widget content = Padding(padding: padding, child: child);

    if (accentBarColor != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: DecoratedBox(decoration: BoxDecoration(color: accentBarColor)),
          ),
          content,
        ],
      );
    }

    Widget panel = Container(
      width: width,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: content,
    );

    if (onTap != null) {
      panel = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: panel,
        ),
      );
    }

    return panel;
  }
}
