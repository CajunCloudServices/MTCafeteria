String _normalizeTaskBoardJobName(String name) {
  final trimmed = name.trim();
  final beverageVariant = RegExp(r'^Beverages\s+\([A-Z]\)$');
  if (beverageVariant.hasMatch(trimmed)) {
    return 'Beverages';
  }
  return trimmed;
}

bool _isLineJobAvailableToday(String meal, String jobName) {
  final normalizedJobName = _normalizeTaskBoardJobName(jobName);
  if (meal == 'Breakfast' &&
      (normalizedJobName == 'Aloha Plate' || normalizedJobName == 'Choices')) {
    return false;
  }

  final weekday = DateTime.now().weekday;
  final isWeekend =
      weekday == DateTime.saturday || weekday == DateTime.sunday;
  if (isWeekend &&
      (normalizedJobName == 'Aloha Plate' ||
          normalizedJobName == 'Choices' ||
          normalizedJobName == 'Paninis')) {
    return false;
  }

  return true;
}

/// Lightweight job selector option used by the employee task flow.
class JobOption {
  const JobOption({required this.id, required this.name});

  final int id;
  final String name;

  factory JobOption.fromJson(Map<String, dynamic> json) {
    return JobOption(id: json['id'] as int, name: json['name'] as String);
  }
}

/// Checklist item shown in the employee flow for a selected job.
class TaskChecklistItem {
  const TaskChecklistItem({
    required this.taskId,
    required this.phase,
    required this.description,
    required this.requiresCheckoff,
    required this.completed,
  });

  final int taskId;
  final String phase;
  final String description;
  final bool requiresCheckoff;
  final bool completed;

  TaskChecklistItem copyWith({bool? completed}) {
    return TaskChecklistItem(
      taskId: taskId,
      phase: phase,
      description: description,
      requiresCheckoff: requiresCheckoff,
      completed: completed ?? this.completed,
    );
  }

  factory TaskChecklistItem.fromJson(Map<String, dynamic> json) {
    return TaskChecklistItem(
      taskId: json['taskId'] as int,
      phase: json['phase'] as String,
      description: json['description'] as String,
      requiresCheckoff: json['requiresCheckoff'] as bool? ?? true,
      completed: json['completed'] as bool,
    );
  }
}

/// Employee task board payload for the selected meal and job.
class TaskBoard {
  const TaskBoard({
    required this.meals,
    required this.selectedMeal,
    required this.jobs,
    required this.selectedJobId,
    required this.tasks,
  });

  final List<String> meals;
  final String selectedMeal;
  final List<JobOption> jobs;
  final int selectedJobId;
  final List<TaskChecklistItem> tasks;

  TaskBoard copyWith({
    List<String>? meals,
    String? selectedMeal,
    List<JobOption>? jobs,
    int? selectedJobId,
    List<TaskChecklistItem>? tasks,
  }) {
    return TaskBoard(
      meals: meals ?? this.meals,
      selectedMeal: selectedMeal ?? this.selectedMeal,
      jobs: jobs ?? this.jobs,
      selectedJobId: selectedJobId ?? this.selectedJobId,
      tasks: tasks ?? this.tasks,
    );
  }

  factory TaskBoard.fromJson(Map<String, dynamic> json) {
    final rawJobs = (json['jobs'] as List<dynamic>)
        .map((e) => JobOption.fromJson(e as Map<String, dynamic>))
        .toList();
    final uniqueJobs = <JobOption>[];
    final seenNames = <String>{};
    for (final job in rawJobs) {
      final normalizedName = _normalizeTaskBoardJobName(job.name);
      if (!_isLineJobAvailableToday(json['selectedMeal'] as String, normalizedName)) {
        continue;
      }
      if (seenNames.add(normalizedName)) {
        uniqueJobs.add(JobOption(id: job.id, name: normalizedName));
      }
    }

    final rawSelectedJobId = json['selectedJobId'] as int;
    JobOption? selectedRawJob;
    for (final job in rawJobs) {
      if (job.id == rawSelectedJobId) {
        selectedRawJob = job;
        break;
      }
    }
    final selectedNormalizedName = selectedRawJob == null
        ? null
        : _normalizeTaskBoardJobName(selectedRawJob.name);
    var selectedJobId = rawSelectedJobId;
    for (final job in uniqueJobs) {
      if (job.name == selectedNormalizedName) {
        selectedJobId = job.id;
        break;
      }
    }

    return TaskBoard(
      meals: (json['meals'] as List<dynamic>).map((e) => e as String).toList(),
      selectedMeal: json['selectedMeal'] as String,
      jobs: uniqueJobs,
      selectedJobId: selectedJobId,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
