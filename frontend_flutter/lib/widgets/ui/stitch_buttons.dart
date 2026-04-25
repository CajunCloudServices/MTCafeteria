import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Primary CTA as defined by Stitch:
/// `w-full h-12 bg-gradient-to-r from-primary to-primary-container
///  text-on-primary rounded-lg shadow-[0_12px_32px_-8px_rgba(5,17,37,0.15)]
///  font-headline font-bold active:scale-[0.98]`.
class StitchPrimaryButton extends StatelessWidget {
  const StitchPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expand = true,
    this.height = StitchLayout.ctaHeight,
    this.loading = false,
    this.disabled = false,
    this.radius = StitchRadii.sm,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;
  final double height;
  final bool loading;
  final bool disabled;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading || onPressed == null;

    final bg = isDisabled
        ? const LinearGradient(
            colors: [StitchColors.surfaceDim, StitchColors.surfaceDim],
          )
        : stitchPrimaryGradient;

    final labelColor = isDisabled
        ? StitchColors.outline
        : StitchColors.onPrimary;

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: height,
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isDisabled ? const [] : StitchShadows.ctaStrong,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: isDisabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (loading) ...[
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(icon, size: 20, color: labelColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: StitchText.buttonMd.copyWith(color: labelColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null && !loading) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, size: 20, color: labelColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary surface button:
/// `bg-surface-container text-primary font-label font-bold h-12 rounded-lg`.
class StitchSecondaryButton extends StatelessWidget {
  const StitchSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expand = true,
    this.height = StitchLayout.ctaHeight,
    this.background = StitchColors.surfaceContainerHigh,
    this.foreground = StitchColors.primary,
    this.radius = StitchRadii.sm,
    this.border = StitchColors.outlineVariant,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;
  final double height;
  final Color background;
  final Color foreground;
  final double radius;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final fg = disabled ? StitchColors.outline : foreground;
    final resolvedBorder =
        border ?? StitchColors.outlineVariant.withValues(alpha: 0.9);

    final inner = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: StitchText.buttonSm.copyWith(color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 20, color: fg),
        ],
      ],
    );

    final button = SizedBox(
      height: height,
      child: Material(
        color: disabled
            ? StitchColors.surfaceContainerHighest.withValues(alpha: 0.9)
            : background,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: resolvedBorder),
            ),
            child: inner,
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Ghost / outline button:
/// `bg-transparent text-primary hover:bg-surface-container`.
class StitchGhostButton extends StatelessWidget {
  const StitchGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.foreground = StitchColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return StitchSecondaryButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expand: expand,
      background: Colors.transparent,
      foreground: foreground,
    );
  }
}
