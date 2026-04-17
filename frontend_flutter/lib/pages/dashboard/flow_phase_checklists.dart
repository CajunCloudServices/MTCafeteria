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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9FB6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (tasks.isEmpty)
            const SizedBox.shrink()
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onToggle(slot, task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                    ),
            ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9FB6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (tasks.isEmpty)
            const SizedBox.shrink()
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onTaskToggle(task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                    ),
            ),
        ],
      ),
    );
  }
}
