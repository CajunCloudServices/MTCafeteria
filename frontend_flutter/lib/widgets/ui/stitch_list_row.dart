import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';
import 'stitch_card.dart';

/// Stitch tile / list row used for "choose a job", "jump back in", supervisor
/// dashboards, etc. Matches:
/// ```
/// bg-surface-container-lowest rounded-xl p-4 flex items-center gap-4
/// shadow-[0_12px_32px_-8px_rgba(5,17,37,0.08)]
/// leading icon pill + two-line text + chevron.
/// ```
class StitchListRow extends StatelessWidget {
  const StitchListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingBackground = StitchColors.primary,
    this.leadingForeground = StitchColors.onPrimary,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(StitchSpacing.lg),
    this.titleStyle,
    this.subtitleStyle,
    this.elevation = StitchCardElevation.card,
    this.surface = StitchSurface.lowest,
    this.accentBarColor,
    this.leadingSize = 48,
    this.leadingRadius = StitchRadii.md,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final Color leadingBackground;
  final Color leadingForeground;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final StitchCardElevation elevation;
  final StitchSurface surface;
  final Color? accentBarColor;
  final double leadingSize;
  final double leadingRadius;

  @override
  Widget build(BuildContext context) {
    final Widget? leadingWidget =
        leading ??
        (leadingIcon == null
            ? null
            : Container(
                height: leadingSize,
                width: leadingSize,
                decoration: BoxDecoration(
                  color: leadingBackground,
                  borderRadius: BorderRadius.circular(leadingRadius),
                ),
                alignment: Alignment.center,
                child: Icon(
                  leadingIcon,
                  color: leadingForeground,
                  size: leadingSize >= 48 ? 26 : 22,
                ),
              ));

    return StitchCard(
      padding: padding,
      elevation: elevation,
      surface: surface,
      onTap: onTap,
      accentBarColor: accentBarColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: StitchSpacing.lg),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ?? StitchText.titleSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style:
                        subtitleStyle ??
                        StitchText.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: StitchColors.onSurfaceVariant,
              size: 22,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact checklist row with a trailing status indicator.
class StitchCheckRow extends StatelessWidget {
  const StitchCheckRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.checked,
    this.onChanged,
    this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      elevation: StitchCardElevation.subtle,
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20, color: StitchColors.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: StitchText.bodyStrong.copyWith(
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color: checked
                        ? StitchColors.onSurfaceVariant
                        : StitchColors.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: StitchText.caption),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: checked
                  ? StitchColors.primary
                  : StitchColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(StitchRadii.xs),
              border: Border.all(
                color: checked
                    ? StitchColors.primary
                    : StitchColors.outlineVariant,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: checked
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: StitchColors.onPrimary,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
