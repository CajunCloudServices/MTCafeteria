import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';
import 'stitch_buttons.dart';
import 'stitch_card.dart';

/// Canonical checklist row used everywhere a task needs a checkbox + label.
/// Compact sizing keeps task lists dense so more items fit on one screen.
/// - 1px left accent ribbon for completed / required states
/// - 22x22 rounded checkbox (primary when checked, outline when pending,
///   error border when required)
/// - Title + optional subtitle (strike-through at 70% when completed)
/// - Optional trailing "REQUIRED" badge
class StitchChecklistTile extends StatelessWidget {
  const StitchChecklistTile({
    super.key,
    required this.title,
    this.subtitle,
    this.checked = false,
    this.required = false,
    this.onChanged,
    this.trailing,
    this.readOnly = false,
  });

  final String title;
  final String? subtitle;
  final bool checked;
  final bool required;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final onChangedLocal = onChanged;
    final disabled = readOnly || onChangedLocal == null;
    final Color accent = checked
        ? StitchColors.secondaryFixed
        : (required ? StitchColors.error : Colors.transparent);

    return Opacity(
      opacity: checked ? 0.84 : 1,
      child: StitchCard(
        padding: const EdgeInsets.fromLTRB(22, 18, 20, 18),
        elevation: StitchCardElevation.card,
        ring: true,
        ringColor: required && !checked
            ? StitchColors.error.withValues(alpha: 0.4)
            : null,
        accentBarColor: accent == Colors.transparent ? null : accent,
        onTap: disabled ? null : () => onChangedLocal(!checked),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (readOnly)
              const _StitchContinuousIndicator()
            else
              _StitchCheckbox(
                checked: checked,
                required: required,
                onChanged: disabled ? null : onChangedLocal,
              ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: StitchText.titleSm.copyWith(
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: StitchText.bodyLg.copyWith(
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 14),
              trailing!,
            ] else if (required && !checked) ...[
              const SizedBox(width: 14),
              const _RequiredBadge(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StitchContinuousIndicator extends StatelessWidget {
  const _StitchContinuousIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLow,
        shape: BoxShape.circle,
        border: Border.all(color: StitchColors.outlineVariant, width: 1.25),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.autorenew_rounded,
        size: 17,
        color: StitchColors.onSurfaceVariant,
      ),
    );
  }
}

class _StitchCheckbox extends StatelessWidget {
  const _StitchCheckbox({
    required this.checked,
    required this.required,
    required this.onChanged,
  });

  final bool checked;
  final bool required;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    if (checked) {
      border = StitchColors.primary;
      bg = StitchColors.primary;
    } else if (required) {
      border = StitchColors.error.withValues(alpha: 0.75);
      bg = Colors.transparent;
    } else {
      border = StitchColors.outline;
      bg = Colors.transparent;
    }

    return SizedBox(
      width: 29,
      height: 29,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(StitchRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
          onTap: onChanged == null ? null : () => onChanged!(!checked),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StitchRadii.sm),
              border: Border.all(color: border, width: 1.75),
            ),
            alignment: Alignment.center,
            child: checked
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: StitchColors.onPrimary,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: StitchColors.errorContainer,
        borderRadius: BorderRadius.circular(StitchRadii.pill),
      ),
      child: Text(
        'REQUIRED',
        style: StitchText.eyebrowBold.copyWith(
          color: StitchColors.onErrorContainer,
        ),
      ),
    );
  }
}

/// Readiness / progress card.
///
/// `font-headline bold + "X of Y Completed"` caption, full-width bar at h-3.
class StitchProgressCard extends StatelessWidget {
  const StitchProgressCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    this.leadingIcon,
  });

  final String title;
  final int completed;
  final int total;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: StitchColors.primary),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(title, style: StitchText.titleMd)),
              Text(
                '$completed of $total Completed',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(StitchRadii.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: StitchColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(
                StitchColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch "Shift Complete" success card.
///
/// Mirrors `shift_complete/code.html`:
/// - Round icon tile w/ secondary-container background
/// - 30px editorial headline + short copy
/// - Two 1:1 stat tiles
/// - Full-width gradient CTA
class StitchSuccessCard extends StatelessWidget {
  const StitchSuccessCard({
    super.key,
    required this.title,
    this.message = '',
    this.icon = Icons.task_alt_rounded,
    this.stats = const [],
    required this.primaryCtaLabel,
    required this.onPrimary,
    this.secondaryCtaLabel,
    this.onSecondary,
    this.primaryIcon = Icons.dashboard_rounded,
  });

  final String title;
  final String message;
  final IconData icon;
  final List<StitchSuccessStat> stats;
  final String primaryCtaLabel;
  final VoidCallback onPrimary;
  final String? secondaryCtaLabel;
  final VoidCallback? onSecondary;
  final IconData primaryIcon;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      elevation: StitchCardElevation.card,
      surface: StitchSurface.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: StitchColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 48,
                color: StitchColors.onSecondaryFixedVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: StitchText.display, textAlign: TextAlign.center),
          if (message.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              message,
              style: StitchText.bodyLg.copyWith(
                color: StitchColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _StatTile(stat: stats[i])),
                ],
              ],
            ),
          ],
          const SizedBox(height: 28),
          StitchPrimaryButton(
            label: primaryCtaLabel,
            icon: primaryIcon,
            onPressed: onPrimary,
            height: StitchLayout.ctaHeightLg,
          ),
          if (secondaryCtaLabel != null && onSecondary != null) ...[
            const SizedBox(height: 12),
            StitchSecondaryButton(
              label: secondaryCtaLabel!,
              onPressed: onSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class StitchSuccessStat {
  const StitchSuccessStat({required this.value, required this.label});

  final String value;
  final String label;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final StitchSuccessStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchRadii.md),
      ),
      child: Column(
        children: [
          Text(stat.value, style: StitchText.metricSm),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: StitchText.bodyStrong.copyWith(
              color: StitchColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch section header: eyebrow + editorial headline.
///
/// Used above checklists and shift-running panels.
class StitchFlowHeader extends StatelessWidget {
  const StitchFlowHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.subtitleWidget,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(eyebrow.toUpperCase(), style: StitchText.eyebrow),
              const SizedBox(height: 6),
              Text(title, style: StitchText.display),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: StitchText.bodyLg),
              ],
              if (subtitleWidget != null) ...[
                const SizedBox(height: 10),
                subtitleWidget!,
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}
