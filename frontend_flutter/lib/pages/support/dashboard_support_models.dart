part of '../dashboard_support_sections.dart';

/// Local checklist item used by the prototype support-track flows that are not
/// yet backed by shared API task data.
class LocalChecklistTask {
  const LocalChecklistTask({
    required this.id,
    required this.description,
    required this.requiresCheckoff,
  });

  final String id;
  final String description;
  final bool requiresCheckoff;
}

/// Local-only job definition for dishroom, kitchen jobs, and night custodial.
class LocalJobDefinition {
  const LocalJobDefinition({
    required this.name,
    required this.setup,
    required this.during,
    required this.cleanup,
  });

  final String name;
  final List<LocalChecklistTask> setup;
  final List<LocalChecklistTask> during;
  final List<LocalChecklistTask> cleanup;
}
