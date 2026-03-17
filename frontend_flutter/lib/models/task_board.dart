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

  factory TaskBoard.fromJson(Map<String, dynamic> json) {
    return TaskBoard(
      meals: (json['meals'] as List<dynamic>).map((e) => e as String).toList(),
      selectedMeal: json['selectedMeal'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => JobOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedJobId: json['selectedJobId'] as int,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
