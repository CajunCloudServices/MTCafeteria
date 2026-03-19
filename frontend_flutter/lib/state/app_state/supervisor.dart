part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateSupervisor on AppState {
  void _clearSupervisorWorkflowState() {
    supervisorSecondaries = [
      for (final item in AppState._defaultSupervisorSecondaries)
        item.copyWith(checked: false),
    ];
    supervisorDeepCleanChecks = const {};
    supervisorPanelMode = 'Jobs';
    supervisorSelectedJobId = null;
    supervisorJobTaskBoard = null;
  }

  Future<void> refreshSupervisorBoard({String? meal}) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    final board = await _apiClient.getSupervisorBoard(_token!, meal: meal);
    supervisorBoard = board;
    if (meal != null &&
        supervisorJobTaskBoard != null &&
        supervisorJobTaskBoard!.meal != board.selectedMeal) {
      // Meal switches invalidate any open job detail drawer.
      supervisorJobTaskBoard = null;
      supervisorSelectedJobId = null;
    }
    await loadCurrentLineShiftReport(meal: board.selectedMeal);
    _stateChanged();
  }

  Future<void> setSupervisorJobCheck({
    required int jobId,
    required bool checked,
  }) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    await _apiClient.setSupervisorJobCheck(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: jobId,
      checked: checked,
    );
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
  }

  Future<void> resetSupervisorChecks() async {
    _clearSupervisorWorkflowState();

    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      _stateChanged();
      return;
    }
    await _apiClient.resetSupervisorBoard(
      _token!,
      meal: supervisorBoard!.selectedMeal,
    );
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
  }

  Future<void> openSupervisorJobTasks(int jobId) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    final board = await _apiClient.getSupervisorJobTasks(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: jobId,
    );
    supervisorSelectedJobId = jobId;
    supervisorJobTaskBoard = board;
    supervisorPanelMode = 'Jobs';
    _stateChanged();
  }

  void closeSupervisorJobTasks() {
    supervisorSelectedJobId = null;
    supervisorJobTaskBoard = null;
    _stateChanged();
  }

  void setSupervisorPanelMode(String mode) {
    supervisorPanelMode = mode;
    _stateChanged();
  }

  void toggleSecondaryJob(int index, bool checked) {
    supervisorSecondaries = [
      for (var i = 0; i < supervisorSecondaries.length; i += 1)
        i == index
            ? supervisorSecondaries[i].copyWith(checked: checked)
            : supervisorSecondaries[i],
    ];
    _stateChanged();
  }

  void resetSecondaryJobs() {
    supervisorSecondaries = [
      for (final item in AppState._defaultSupervisorSecondaries)
        item.copyWith(checked: false),
    ];
    supervisorDeepCleanChecks = const {};
    _stateChanged();
  }

  bool get isSupervisorDeepCleanChecked {
    final meal = supervisorBoard?.selectedMeal;
    if (meal == null) return false;
    final weekday = DateTime.now().weekday;
    // Deep-clean status is tracked per meal/day combination so a breakfast
    // check does not leak into lunch or another weekday.
    final key = '$meal|$weekday';
    return supervisorDeepCleanChecks[key] ?? false;
  }

  void toggleSupervisorDeepClean(bool checked) {
    final meal = supervisorBoard?.selectedMeal;
    if (meal == null) return;
    final weekday = DateTime.now().weekday;
    final key = '$meal|$weekday';
    supervisorDeepCleanChecks = {...supervisorDeepCleanChecks, key: checked};
    _stateChanged();
  }

  Future<void> setSupervisorTaskCheck({
    required int taskId,
    required bool checked,
  }) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null ||
        supervisorSelectedJobId == null) {
      return;
    }

    final meal = supervisorBoard!.selectedMeal;
    final jobId = supervisorSelectedJobId!;

    await _apiClient.setSupervisorTaskCheck(
      _token!,
      meal: meal,
      jobId: jobId,
      taskId: taskId,
      checked: checked,
    );

    // Keep the list summary in sync. Only refresh the open job detail if the
    // user is still on that same job; this avoids visible UI bounce when they
    // intentionally navigate back to Jobs.
    await refreshSupervisorBoard(meal: meal);
    if (supervisorSelectedJobId == jobId) {
      await openSupervisorJobTasks(jobId);
    }
  }

  Future<void> setSupervisorTaskChecksBulk({
    required List<int> taskIds,
    required bool checked,
  }) async {
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null ||
        supervisorSelectedJobId == null ||
        taskIds.isEmpty) {
      return;
    }

    final meal = supervisorBoard!.selectedMeal;
    final jobId = supervisorSelectedJobId!;

    // Bulk completion intentionally fan-outs requests in parallel; the original
    // serial implementation felt laggy on larger cleanup lists.
    await Future.wait(
      taskIds.map(
        (taskId) => _apiClient.setSupervisorTaskCheck(
          _token!,
          meal: meal,
          jobId: jobId,
          taskId: taskId,
          checked: checked,
        ),
      ),
    );

    await refreshSupervisorBoard(meal: meal);
    if (supervisorSelectedJobId == jobId) {
      await openSupervisorJobTasks(jobId);
    }
  }
}
