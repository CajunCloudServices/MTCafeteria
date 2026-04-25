import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Uppercase eyebrow + big headline section introduction, as used on every
/// Stitch screen above a list of cards.
class StitchSectionHeader extends StatelessWidget {
  const StitchSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.dense = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: StitchText.eyebrow),
              SizedBox(height: dense ? 4 : 6),
              Text(title, style: StitchText.titleLg),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: StitchText.bodyLg.copyWith(
                    color: StitchColors.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// Thin accent bar (2px wide, 12–16px tall) + short uppercase label used as a
/// micro-eyebrow in cards.
class StitchAccentEyebrow extends StatelessWidget {
  const StitchAccentEyebrow({
    super.key,
    required this.label,
    this.accentColor = StitchColors.primary,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2,
          height: 14,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(StitchRadii.xs),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: StitchText.bodyStrong.copyWith(color: accentColor),
        ),
      ],
    );
  }
}

/// Two-column stat block (big metric + caption beneath).
class StitchMetric extends StatelessWidget {
  const StitchMetric({
    super.key,
    required this.value,
    required this.label,
    this.accentColor = StitchColors.primary,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: StitchText.metric.copyWith(color: accentColor)),
        const SizedBox(height: 4),
        Text(
          label,
          style: StitchText.bodyStrong.copyWith(
            color: StitchColors.onSurface,
          ),
        ),
      ],
    );
  }
}
