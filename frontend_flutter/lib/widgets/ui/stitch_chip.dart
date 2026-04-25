import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Status / eyebrow chip tones available in the Stitch design.
enum StitchChipTone { neutral, primary, secondary, tertiary, error, success }

/// Small status / label chip.
///
/// Matches `px-2.5 py-1 rounded-full bg-X text-Y font-label text-[10-11px]
/// uppercase tracking-widest font-bold` patterns from Stitch.
class StitchChip extends StatelessWidget {
  const StitchChip({
    super.key,
    required this.label,
    this.tone = StitchChipTone.neutral,
    this.uppercase = true,
    this.dense = false,
    this.icon,
    this.filled = true,
  });

  final String label;
  final StitchChipTone tone;
  final bool uppercase;
  final bool dense;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final (_, fg) = _toneColors(tone, filled);
    final effectiveLabel = uppercase ? label.toUpperCase() : label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: dense ? 15 : 16, color: fg),
          const SizedBox(width: 6),
        ],
        Text(
          effectiveLabel,
          style: StitchText.bodyStrong.copyWith(
            color: fg,
            fontSize: dense ? 14 : 15,
            letterSpacing: uppercase ? 0.2 : 0,
          ),
        ),
      ],
    );
  }

  (Color, Color) _toneColors(StitchChipTone t, bool filled) {
    if (!filled) {
      // Outline variant.
      switch (t) {
        case StitchChipTone.primary:
          return (Colors.transparent, StitchColors.primary);
        case StitchChipTone.secondary:
          return (Colors.transparent, StitchColors.onSecondaryFixedVariant);
        case StitchChipTone.tertiary:
          return (Colors.transparent, StitchColors.onTertiaryFixedVariant);
        case StitchChipTone.error:
          return (Colors.transparent, StitchColors.onErrorContainer);
        case StitchChipTone.success:
          return (Colors.transparent, StitchColors.onSecondaryFixedVariant);
        case StitchChipTone.neutral:
          return (Colors.transparent, StitchColors.onSurfaceVariant);
      }
    }
    switch (t) {
      case StitchChipTone.primary:
        return (StitchColors.primary, StitchColors.onPrimary);
      case StitchChipTone.secondary:
        return (
          StitchColors.secondaryContainer,
          StitchColors.onSecondaryFixedVariant,
        );
      case StitchChipTone.tertiary:
        return (StitchColors.tertiaryFixed, StitchColors.onTertiaryFixedVariant);
      case StitchChipTone.error:
        return (StitchColors.errorContainer, StitchColors.onErrorContainer);
      case StitchChipTone.success:
        return (
          StitchColors.secondaryContainer,
          StitchColors.onSecondaryFixedVariant,
        );
      case StitchChipTone.neutral:
        return (StitchColors.surfaceContainerHigh, StitchColors.onSurfaceVariant);
    }
  }
}

/// Horizontally-scrollable filter chip row.
/// Matches the Stitch "All Guides / Safety / Equipment / …" bar.
class StitchFilterChipBar extends StatelessWidget {
  const StitchFilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.iconFor,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final IconData? Function(int index)? iconFor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          final icon = iconFor?.call(i);
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(StitchRadii.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(StitchRadii.sm),
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? StitchColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: selected
                            ? StitchColors.primary
                            : StitchColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[i],
                      style: StitchText.buttonSm.copyWith(
                        color: selected
                            ? StitchColors.primary
                            : StitchColors.onSurfaceVariant,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
