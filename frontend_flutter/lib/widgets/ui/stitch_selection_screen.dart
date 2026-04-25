import 'package:flutter/material.dart';

import '../../theme/app_bar_title_override.dart';
import '../../theme/stitch_tokens.dart';
import 'stitch_buttons.dart';
import 'stitch_list_row.dart';

/// Canonical selection screen used by every "pick one" step in the app:
/// shift area, role, meal, station, section, etc.
///
/// The screen title is pushed into [appBarTitleOverride] so the shared app
/// bar in `main.dart` renders it — no inline heading, no duplicated title.
/// Content layout: flat list of tiles + Continue button, centered vertically
/// when the list fits, scrolling from the top when it overflows.
class StitchSelectionScreen extends StatefulWidget {
  const StitchSelectionScreen({
    super.key,
    required this.title,
    required this.options,
    this.continueLabel,
    this.onContinue,
    this.isBusy = false,
  });

  final String title;
  final List<StitchSelectionOption> options;
  final String? continueLabel;
  final VoidCallback? onContinue;
  final bool isBusy;

  @override
  State<StitchSelectionScreen> createState() => _StitchSelectionScreenState();
}

class _StitchSelectionScreenState extends State<StitchSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _pushTitle();
  }

  @override
  void didUpdateWidget(covariant StitchSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _pushTitle();
    }
  }

  @override
  void dispose() {
    _clearTitleDeferred();
    super.dispose();
  }

  void _pushTitle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      appBarTitleOverride.value = widget.title;
    });
  }

  void _clearTitleDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only clear if our title is still the active override — otherwise a
      // sibling selection screen has already taken over and we shouldn't stomp.
      if (appBarTitleOverride.value == widget.title) {
        appBarTitleOverride.value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.options.length; i++) ...[
          if (i > 0) const SizedBox(height: StitchSpacing.md),
          () {
            final opt = widget.options[i];
            final enabled = opt.onTap != null;
            final leadingBg = enabled
                ? StitchColors.surfaceContainer
                : StitchColors.surfaceContainerLowest;
            final leadingFg = enabled
                ? StitchColors.primary
                : StitchColors.onSurfaceVariant;
            final TextStyle? titleStyle = enabled
                ? null
                : StitchText.titleSm.copyWith(
                    color: StitchColors.onSurfaceVariant,
                  );

            return StitchListRow(
              key: opt.rowKey,
              title: opt.label,
              leadingIcon: opt.icon,
              leadingBackground: leadingBg,
              leadingForeground: leadingFg,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: StitchColors.onSurfaceVariant,
                size: 24,
              ),
              onTap: opt.onTap,
              titleStyle: titleStyle,
            );
          }(),
        ],
        if (widget.continueLabel != null) ...[
          const SizedBox(height: StitchSpacing.xl),
          StitchPrimaryButton(
            label: widget.continueLabel!,
            onPressed: widget.isBusy ? null : widget.onContinue,
            trailingIcon: Icons.arrow_forward_rounded,
            loading: widget.isBusy,
          ),
        ],
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: StitchLayout.mobileMaxWidth,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use the same MediaQuery-derived height for both bounded and
            // unbounded parents so every selection screen (Area, Role, Meal,
            // etc.) centers at the exact same y position regardless of
            // whether it's mounted directly under the Scaffold body or
            // nested inside a parent SingleChildScrollView.
            final media = MediaQuery.of(context);
            final targetMinHeight =
                (media.size.height -
                        media.padding.vertical -
                        kToolbarHeight -
                        kBottomNavigationBarHeight -
                        36) // page padding top (16) + bottom (20)
                    .clamp(0.0, media.size.height);
            final centered = ConstrainedBox(
              constraints: BoxConstraints(minHeight: targetMinHeight),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: column,
                ),
              ),
            );
            // Bounded parent: wrap in SingleChildScrollView so overflow is
            // scrollable. Unbounded parent: the parent SingleChildScrollView
            // already scrolls — nesting another would crash.
            return constraints.hasBoundedHeight
                ? SingleChildScrollView(child: centered)
                : centered;
          },
        ),
      ),
    );
  }
}

/// A single option rendered inside [StitchSelectionScreen].
class StitchSelectionOption {
  const StitchSelectionOption({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
    this.rowKey,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final Key? rowKey;
}
