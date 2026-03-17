/// Job selector option for the lead trainer support board.
class TrainerJobOption {
  const TrainerJobOption({required this.id, required this.name});

  final int id;
  final String name;

  factory TrainerJobOption.fromJson(Map<String, dynamic> json) {
    return TrainerJobOption(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// Task row displayed under a trainer's assigned trainee job.
class TrainerTraineeTask {
  const TrainerTraineeTask({
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

  factory TrainerTraineeTask.fromJson(Map<String, dynamic> json) {
    return TrainerTraineeTask(
      taskId: json['taskId'] as int,
      phase: json['phase'] as String,
      description: json['description'] as String,
      requiresCheckoff: json['requiresCheckoff'] as bool? ?? true,
      completed: json['completed'] as bool,
    );
  }
}

/// A trainee card returned by the backend trainer board endpoint.
class TrainerTraineeCard {
  const TrainerTraineeCard({
    required this.traineeUserId,
    required this.traineeName,
    required this.jobId,
    required this.jobName,
    required this.tasks,
  });

  final int traineeUserId;
  final String traineeName;
  final int jobId;
  final String jobName;
  final List<TrainerTraineeTask> tasks;

  factory TrainerTraineeCard.fromJson(Map<String, dynamic> json) {
    return TrainerTraineeCard(
      traineeUserId: json['traineeUserId'] as int,
      traineeName: json['traineeName'] as String,
      jobId: json['jobId'] as int,
      jobName: json['jobName'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TrainerTraineeTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Lead trainer board payload for the selected meal and trainee jobs.
class TrainerBoard {
  const TrainerBoard({
    required this.meals,
    required this.selectedMeal,
    required this.jobs,
    required this.selectedJobIds,
    required this.trainees,
  });

  final List<String> meals;
  final String selectedMeal;
  final List<TrainerJobOption> jobs;
  final List<int> selectedJobIds;
  final List<TrainerTraineeCard> trainees;

  factory TrainerBoard.fromJson(Map<String, dynamic> json) {
    return TrainerBoard(
      meals: (json['meals'] as List<dynamic>).map((e) => e as String).toList(),
      selectedMeal: json['selectedMeal'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => TrainerJobOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedJobIds: (json['selectedJobIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      trainees: (json['trainees'] as List<dynamic>)
          .map((e) => TrainerTraineeCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
