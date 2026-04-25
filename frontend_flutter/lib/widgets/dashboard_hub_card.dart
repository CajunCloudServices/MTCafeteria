import 'package:flutter/material.dart';

import '../theme/stitch_tokens.dart';
import 'ui/stitch_card.dart';
import 'ui/tester_welcome_dialog.dart';

/// Stitch-aligned dashboard launcher. Mirrors `dashboard_hub/code.html`.
class DashboardHubCard extends StatefulWidget {
  const DashboardHubCard({
    super.key,
    required this.canOpenReference,
    required this.canOpenFindItem,
    required this.canOpenDiningMap,
    required this.canViewTrainings,
    required this.canOpenManagerPortal,
    required this.onOpenWorkflow,
    required this.onOpenFindItem,
    required this.onOpenDiningMap,
    required this.onOpenManagerPortal,
    required this.onOpenAppFeedback,
    required this.onOpenTrainings,
    required this.onOpenReference,
  });

  final bool canOpenReference;
  final bool canOpenFindItem;
  final bool canOpenDiningMap;
  final bool canViewTrainings;
  final bool canOpenManagerPortal;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenFindItem;
  final VoidCallback onOpenDiningMap;
  final VoidCallback onOpenManagerPortal;
  final VoidCallback onOpenAppFeedback;
  final VoidCallback onOpenTrainings;
  final VoidCallback onOpenReference;

  @override
  State<DashboardHubCard> createState() => _DashboardHubCardState();
}

class _DashboardHubCardState extends State<DashboardHubCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TesterWelcomeDialog.maybeShow(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSecondary = widget.canOpenFindItem || widget.canOpenDiningMap;
    final showManagement = widget.canOpenManagerPortal;

    final hasKnowledge = widget.canOpenReference || widget.canViewTrainings;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryStartShiftCta(onPressed: widget.onOpenWorkflow),
        if (showSecondary) ...[
          const SizedBox(height: StitchSpacing.lg),
          Row(
            children: [
              if (widget.canOpenFindItem)
                Expanded(
                  child: _HubTile(
                    icon: Icons.search_rounded,
                    label: 'Find an Item',
                    onPressed: widget.onOpenFindItem,
                  ),
                ),
              if (widget.canOpenFindItem && widget.canOpenDiningMap)
                const SizedBox(width: StitchSpacing.lg),
              if (widget.canOpenDiningMap)
                Expanded(
                  child: _HubTile(
                    icon: Icons.map_outlined,
                    label: 'Dining Map',
                    onPressed: widget.onOpenDiningMap,
                  ),
                ),
            ],
          ),
        ],
        if (hasKnowledge) ...[
          const SizedBox(height: StitchSpacing.xl2),
          if (widget.canOpenReference)
            _KnowledgeRow(
              icon: Icons.menu_book_outlined,
              title: 'Guides',
              onTap: widget.onOpenReference,
            ),
          if (widget.canOpenReference && widget.canViewTrainings)
            const SizedBox(height: StitchSpacing.md),
          if (widget.canViewTrainings)
            _KnowledgeRow(
              icon: Icons.timer_outlined,
              title: '2-Minute Trainings',
              onTap: widget.onOpenTrainings,
            ),
        ],
        const SizedBox(height: StitchSpacing.md),
        _KnowledgeRow(
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          onTap: widget.onOpenAppFeedback,
        ),
        if (showManagement) ...[
          const SizedBox(height: StitchSpacing.md),
          _KnowledgeRow(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Student Manager Portal',
            onTap: widget.onOpenManagerPortal,
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: column,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryStartShiftCta extends StatelessWidget {
  const _PrimaryStartShiftCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchRadii.md),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: stitchPrimaryGradient,
            borderRadius: BorderRadius.circular(StitchRadii.md),
            boxShadow: StitchShadows.cardSoft,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StitchSpacing.xl2,
              vertical: StitchSpacing.xl2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Start Shift',
                        style: TextStyle(
                          fontFamily: StitchFonts.headline,
                          fontFamilyFallback: StitchFonts.fallback,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: StitchColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: StitchColors.surface.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: StitchColors.onPrimary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      onTap: onPressed,
      padding: const EdgeInsets.all(StitchSpacing.xl),
      elevation: StitchCardElevation.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(StitchRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: StitchColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: StitchText.titleXs,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _KnowledgeRow extends StatelessWidget {
  const _KnowledgeRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      onTap: onTap,
      padding: const EdgeInsets.all(StitchSpacing.lg),
      elevation: StitchCardElevation.subtle,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainer,
              borderRadius: BorderRadius.circular(StitchRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: StitchColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: StitchSpacing.lg),
          Expanded(
            child: Text(title, style: StitchText.titleXs),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: StitchColors.outline,
            size: 22,
          ),
        ],
      ),
    );
  }
}
