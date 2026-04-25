part of '../dashboard_support_sections.dart';

/// Instruction/reference box used above support-track checklists.
class InstructionCard extends StatelessWidget {
  const InstructionCard({
    super.key,
    required this.lines,
    this.textStyle,
  });

  final List<String> lines;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Text(
            lines[i],
            style:
                textStyle ??
                StitchText.bodyLg.copyWith(color: StitchColors.onSurface),
          ),
        ],
      ],
    );
  }
}

/// Reusable phase checklist for local-only support sections.
class LocalPhaseChecklist extends StatelessWidget {
  const LocalPhaseChecklist({
    super.key,
    required this.title,
    required this.tasks,
    required this.checks,
    required this.onToggle,
  });

  final String title;
  final List<LocalChecklistTask> tasks;
  final Map<String, bool> checks;
  final void Function(String id, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    final checkoffTotal = tasks.where((t) => t.requiresCheckoff).length;
    final checkoffDone = tasks
        .where((t) => t.requiresCheckoff && (checks[t.id] ?? false))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.md),
          elevation: StitchCardElevation.subtle,
          surface: StitchSurface.low,
          ring: true,
          child: StitchProgressCard(
            title: title,
            completed: checkoffDone,
            total: checkoffTotal,
            leadingIcon: Icons.checklist_rounded,
          ),
        ),
        const SizedBox(height: StitchSpacing.lg),
        StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.md),
          elevation: StitchCardElevation.subtle,
          surface: StitchSurface.low,
          ring: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < tasks.length; index++) ...[
                Builder(
                  builder: (context) {
                    final task = tasks[index];
                    if (task.requiresCheckoff) {
                      return StitchChecklistTile(
                        title: task.description,
                        checked: checks[task.id] ?? false,
                        onChanged: (value) => onToggle(task.id, value),
                      );
                    }
                    return StitchChecklistTile(
                      title: task.description,
                      readOnly: true,
                    );
                  },
                ),
                if (index < tasks.length - 1)
                  const SizedBox(height: StitchSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Lightweight finish card for prototype flows without backend persistence.
class SimpleFinishCard extends StatelessWidget {
  const SimpleFinishCard({
    super.key,
    required this.title,
    required this.message,
    this.onReturn,
  });

  final String title;
  final String message;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    return StitchSuccessCard(
      title: title,
      message: message,
      stats: const [],
      primaryCtaLabel: 'Back to Dashboard',
      primaryIcon: Icons.dashboard_rounded,
      onPrimary: onReturn ?? () {},
    );
  }
}

/// Consistent section heading used across support-track cards.
class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: StitchColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: StitchText.titleLg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
