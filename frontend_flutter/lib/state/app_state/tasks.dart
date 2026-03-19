part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateTasks on AppState {
  Future<void> refreshTaskBoard({
    String? meal,
    int? jobId,
    String? preferredJobName,
  }) async {
    if (!isAuthenticated) return;
    final board = await _apiClient.getTaskBoard(
      _token!,
      meal: meal,
      jobId: jobId,
      preferredJobName: preferredJobName,
    );
    taskBoard = board;
    _stateChanged();
  }

  Future<void> selectMealKeepJob(String meal) async {
    if (!isAuthenticated) return;

    final currentBoard = taskBoard;
    String? currentJobName;
    if (currentBoard != null) {
      // Meal changes should preserve the worker's selected job when the same
      // job exists across meals.
      for (final job in currentBoard.jobs) {
        if (job.id == currentBoard.selectedJobId) {
          currentJobName = job.name;
          break;
        }
      }
    }

    await refreshTaskBoard(meal: meal, preferredJobName: currentJobName);
  }

  Future<void> setTaskCompletion({
    required int taskId,
    required bool completed,
  }) async {
    if (!isAuthenticated) return;
    await _apiClient.setTaskCompletion(
      _token!,
      taskId: taskId,
      completed: completed,
    );
    await refreshTaskBoard(
      meal: taskBoard?.selectedMeal,
      jobId: taskBoard?.selectedJobId,
    );
  }

  Future<void> resetCurrentTaskFlow({
    required String meal,
    required int jobId,
  }) async {
    if (!isAuthenticated) return;
    await _apiClient.resetTaskFlow(_token!, meal: meal, jobId: jobId);
    await refreshTaskBoard(meal: meal, jobId: jobId);
  }

  Future<void> refreshTrainerBoard({String? meal, List<int>? jobIds}) async {
    if (!isAuthenticated || !canAccessTrainerBoard) return;
    final board = await _apiClient.getTrainerBoard(
      _token!,
      meal: meal,
      jobIds: jobIds,
    );
    trainerBoard = board;
    await _reloadAllTrainerSlotTasks();
    _stateChanged();
  }

  void setTrainerTraineeCount(int count) {
    final normalized = count.clamp(1, 12);
    trainerTraineeCount = normalized;

    // Rebuild slot-backed maps so stale trainee assignments do not survive when
    // the trainer reduces the active trainee count.
    trainerTraineeJobBySlot = {
      for (var i = 0; i < normalized; i += 1) i: trainerTraineeJobBySlot[i],
    };

    trainerSlotTasks = {
      for (final entry in trainerSlotTasks.entries)
        if (entry.key < normalized) entry.key: entry.value,
    };

    if (trainerSelectedTraineeSlot >= normalized) {
      trainerSelectedTraineeSlot = normalized - 1;
    }

    _stateChanged();
  }

  void selectTrainerTraineeSlot(int slot) {
    if (slot < 0 || slot >= trainerTraineeCount) return;
    trainerSelectedTraineeSlot = slot;
    _stateChanged();
  }

  Future<void> setTrainerTraineeJob({
    required int slot,
    required int? jobId,
  }) async {
    if (!isAuthenticated || !canAccessTrainerBoard || trainerBoard == null) {
      return;
    }
    if (slot < 0 || slot >= trainerTraineeCount) return;

    trainerTraineeJobBySlot = {...trainerTraineeJobBySlot, slot: jobId};

    if (jobId == null) {
      trainerSlotTasks = {...trainerSlotTasks, slot: const []};
      _stateChanged();
      return;
    }

    // Lead-trainer slots reuse the same task-board endpoint as employees; the
    // frontend keeps their completion state local to the trainer workflow.
    final board = await _apiClient.getTaskBoard(
      _token!,
      meal: trainerBoard!.selectedMeal,
      jobId: jobId,
    );

    trainerSlotTasks = {
      ...trainerSlotTasks,
      slot: board.tasks
          .map(
            (task) => TrainerTraineeTask(
              taskId: task.taskId,
              phase: task.phase,
              description: task.description,
              requiresCheckoff: task.requiresCheckoff,
              completed: false,
            ),
          )
          .toList(),
    };
    _stateChanged();
  }

  Future<void> setTrainerSlotTaskCompletion({
    required int slot,
    required int taskId,
    required bool completed,
  }) async {
    final tasks = trainerSlotTasks[slot] ?? const [];
    trainerSlotTasks = {
      ...trainerSlotTasks,
      slot: [
        for (final task in tasks)
          task.taskId == taskId
              ? TrainerTraineeTask(
                  taskId: task.taskId,
                  phase: task.phase,
                  description: task.description,
                  requiresCheckoff: task.requiresCheckoff,
                  completed: completed,
                )
              : task,
      ],
    };
    _stateChanged();
  }

  Future<void> _reloadAllTrainerSlotTasks() async {
    if (!isAuthenticated || trainerBoard == null) return;
    for (var slot = 0; slot < trainerTraineeCount; slot += 1) {
      final jobId = trainerTraineeJobBySlot[slot];
      if (jobId == null) continue;
      await setTrainerTraineeJob(slot: slot, jobId: jobId);
    }
  }

  void resetTrainerFlow() {
    trainerTraineeCount = 1;
    trainerSelectedTraineeSlot = 0;
    trainerTraineeJobBySlot = const {0: null};
    trainerSlotTasks = const {};
    _stateChanged();
  }

}
