part of '../dashboard_page.dart';

/// Phase checklist used inside the lead trainer workflow.
class _TrainerPhaseChecklist extends StatelessWidget {
  const _TrainerPhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.slot,
    required this.onToggle,
  });

  final String phase;
  final List<TrainerTraineeTask> tasks;
  final int slot;
  final Future<void> Function(int slot, int taskId, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            top: 8,
            bottom: 12,
          ),
          child: Text(phase, style: StitchText.titleMd),
        ),
        StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          elevation: StitchCardElevation.card,
          surface: StitchSurface.low,
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
                        checked: task.completed,
                        onChanged: (value) => onToggle(slot, task.taskId, value),
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

/// Shared employee phase checklist widget.
class _PhaseChecklist extends StatelessWidget {
  const _PhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.onTaskToggle,
  });

  final String phase;
  final List<TaskChecklistItem> tasks;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;

  int get _completed =>
      tasks.where((t) => t.requiresCheckoff && t.completed).length;
  int get _total => tasks.where((t) => t.requiresCheckoff).length;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.md),
          elevation: StitchCardElevation.subtle,
          surface: StitchSurface.low,
          ring: true,
          child: StitchProgressCard(
            title: phase,
            completed: _completed,
            total: _total,
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
                        checked: task.completed,
                        onChanged: (value) => onTaskToggle(task.taskId, value),
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
