/// A single task grouped under setup, during-shift, or cleanup.
class TaskItem {
  const TaskItem({
    required this.id,
    required this.phase,
    required this.description,
  });

  final int id;
  final String phase;
  final String description;

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      phase: json['phase'] as String,
      description: json['description'] as String,
    );
  }
}

/// A line/dishroom/kitchen job and its phase-specific tasks.
class Job {
  const Job({
    required this.id,
    required this.name,
    required this.setupTasks,
    required this.duringShiftTasks,
    required this.cleanupTasks,
  });

  final int id;
  final String name;
  final List<TaskItem> setupTasks;
  final List<TaskItem> duringShiftTasks;
  final List<TaskItem> cleanupTasks;

  factory Job.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as Map<String, dynamic>;
    return Job(
      id: json['id'] as int,
      name: json['name'] as String,
      setupTasks: ((tasks['setup'] as List<dynamic>?) ?? [])
          .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      duringShiftTasks: ((tasks['duringShift'] as List<dynamic>?) ?? [])
          .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cleanupTasks: ((tasks['cleanup'] as List<dynamic>?) ?? [])
          .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A shift container returned by legacy shift endpoints.
class Shift {
  const Shift({
    required this.id,
    required this.shiftType,
    required this.mealType,
    required this.name,
    required this.jobs,
  });

  final int id;
  final String shiftType;
  final String? mealType;
  final String name;
  final List<Job> jobs;

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      shiftType: json['shiftType'] as String,
      mealType: json['mealType'] as String?,
      name: json['name'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
