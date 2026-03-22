part of '../dashboard_support_sections.dart';

class InstructionCard extends StatelessWidget {
  const InstructionCard({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(
          color: const Color(0xFF1F5E9C).withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines) ...[
            Text(line, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 6),
          ],
        ],
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(
          color: const Color(0xFF9AB3CF).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...tasks.map(
            (task) => task.requiresCheckoff
                ? CheckboxListTile(
                    dense: false,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checks[task.id] ?? false,
                    title: Text(task.description),
                    onChanged: (value) => onToggle(task.id, value ?? false),
                  )
                : ListTile(
                    dense: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    leading: const Icon(Icons.remove, size: 18),
                    title: Text(task.description),
                    subtitle: const Text(
                      'Continuous during-shift responsibility',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight finish card for prototype flows without backend persistence.
class SimpleFinishCard extends StatelessWidget {
  const SimpleFinishCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF103760),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF264D76),
              ),
            ),
          ],
        ),
      ),
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF123A64),
      ),
    );
  }
}
