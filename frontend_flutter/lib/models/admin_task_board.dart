/// Data models for the Task & Job Editor admin flow.
///
/// These mirror the backend payload shape from `/api/task-admin/board` and
/// related CRUD endpoints exactly, so any change here needs a matching tweak
/// on the backend.
class AdminShift {
  const AdminShift({
    required this.id,
    required this.shiftType,
    required this.mealType,
    required this.name,
  });

  factory AdminShift.fromJson(Map<String, dynamic> json) {
    return AdminShift(
      id: (json['id'] as num).toInt(),
      shiftType: json['shiftType'] as String? ?? '',
      mealType: json['mealType'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  final int id;
  final String shiftType;
  final String mealType;
  final String name;
}

class AdminTask {
  const AdminTask({
    required this.id,
    required this.jobId,
    required this.phase,
    required this.description,
    required this.requiresCheckoff,
  });

  factory AdminTask.fromJson(Map<String, dynamic> json) {
    return AdminTask(
      id: (json['id'] as num).toInt(),
      jobId: (json['jobId'] as num).toInt(),
      phase: json['phase'] as String? ?? 'Setup',
      description: json['description'] as String? ?? '',
      requiresCheckoff: json['requiresCheckoff'] as bool? ?? true,
    );
  }

  final int id;
  final int jobId;
  final String phase;
  final String description;
  final bool requiresCheckoff;
}

class AdminJob {
  const AdminJob({
    required this.id,
    required this.shiftId,
    required this.name,
    required this.shiftName,
    required this.mealType,
    required this.tasksByPhase,
    required this.totalTaskCount,
  });

  factory AdminJob.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as Map<String, dynamic>? ?? const {};
    final parsed = <String, List<AdminTask>>{};
    for (final entry in rawTasks.entries) {
      final list = (entry.value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminTask.fromJson)
          .toList();
      parsed[entry.key] = list;
    }
    return AdminJob(
      id: (json['id'] as num).toInt(),
      shiftId: (json['shiftId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      shiftName: json['shiftName'] as String?,
      mealType: json['mealType'] as String?,
      tasksByPhase: parsed,
      totalTaskCount: (json['totalTaskCount'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final int shiftId;
  final String name;
  final String? shiftName;
  final String? mealType;
  final Map<String, List<AdminTask>> tasksByPhase;
  final int totalTaskCount;
}

class AdminTaskBoard {
  const AdminTaskBoard({
    required this.shifts,
    required this.jobs,
    required this.phases,
  });

  factory AdminTaskBoard.fromJson(Map<String, dynamic> json) {
    return AdminTaskBoard(
      shifts: (json['shifts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminShift.fromJson)
          .toList(),
      jobs: (json['jobs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminJob.fromJson)
          .toList(),
      phases: (json['phases'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  final List<AdminShift> shifts;
  final List<AdminJob> jobs;
  final List<String> phases;
}
