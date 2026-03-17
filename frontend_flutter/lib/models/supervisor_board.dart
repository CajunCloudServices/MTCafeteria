/// Accepts backend integer fields that sometimes arrive as strings.
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

/// Supervisor-facing summary row for a single job in the selected meal.
class SupervisorJobItem {
  const SupervisorJobItem({
    required this.jobId,
    required this.jobName,
    required this.checked,
    required this.checkedCount,
    required this.totalCount,
  });

  final int jobId;
  final String jobName;
  final bool checked;
  final int checkedCount;
  final int totalCount;

  factory SupervisorJobItem.fromJson(Map<String, dynamic> json) {
    return SupervisorJobItem(
      jobId: _toInt(json['jobId']),
      jobName: json['jobName'] as String,
      checked: json['checked'] as bool,
      checkedCount: _toInt(json['checkedCount']),
      totalCount: _toInt(json['totalCount']),
    );
  }
}

/// Top-level supervisor board model for a meal.
class SupervisorBoard {
  const SupervisorBoard({
    required this.meals,
    required this.selectedMeal,
    required this.jobs,
  });

  final List<String> meals;
  final String selectedMeal;
  final List<SupervisorJobItem> jobs;

  factory SupervisorBoard.fromJson(Map<String, dynamic> json) {
    return SupervisorBoard(
      meals: (json['meals'] as List<dynamic>).map((e) => e as String).toList(),
      selectedMeal: json['selectedMeal'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => SupervisorJobItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A cleanup task that supervisors mark complete for a specific job.
class SupervisorJobTaskItem {
  const SupervisorJobTaskItem({
    required this.taskId,
    required this.phase,
    required this.description,
    required this.checked,
  });

  final int taskId;
  final String phase;
  final String description;
  final bool checked;

  factory SupervisorJobTaskItem.fromJson(Map<String, dynamic> json) {
    return SupervisorJobTaskItem(
      taskId: _toInt(json['taskId']),
      phase: json['phase'] as String,
      description: json['description'] as String,
      checked: json['checked'] as bool,
    );
  }
}

/// Detail view model for a single job's supervisor cleanup checklist.
class SupervisorJobTaskBoard {
  const SupervisorJobTaskBoard({
    required this.meal,
    required this.jobId,
    required this.jobName,
    required this.tasks,
  });

  final String meal;
  final int jobId;
  final String jobName;
  final List<SupervisorJobTaskItem> tasks;

  factory SupervisorJobTaskBoard.fromJson(Map<String, dynamic> json) {
    return SupervisorJobTaskBoard(
      meal: json['meal'] as String,
      jobId: _toInt(json['jobId']),
      jobName: json['jobName'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => SupervisorJobTaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Local-only secondary assignment tracked in the supervisor flow.
class SecondaryJobItem {
  const SecondaryJobItem({
    required this.name,
    required this.phase,
    required this.checked,
    this.meals = const [],
  });

  final String name;
  final String phase;
  final bool checked;
  final List<String> meals;

  SecondaryJobItem copyWith({
    String? phase,
    bool? checked,
    List<String>? meals,
  }) {
    return SecondaryJobItem(
      name: name,
      phase: phase ?? this.phase,
      checked: checked ?? this.checked,
      meals: meals ?? this.meals,
    );
  }
}
