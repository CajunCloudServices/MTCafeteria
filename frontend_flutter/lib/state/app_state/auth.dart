part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateAuth on AppState {
  Future<void> _runBootstrapRefresh(Future<void> Function() refresh) async {
    try {
      await refresh();
    } catch (_) {
      // Best-effort hydration: session auth must succeed even if one
      // feature endpoint is temporarily unhealthy.
    }
  }

  Future<void> _hydrateSession({
    required String email,
    required String password,
  }) async {
    final result = await _apiClient.login(email: email, password: password);
    _token = result.token;
    user = result.user;
    await Future.wait([
      _runBootstrapRefresh(() => refreshLandingItems()),
      if (_features.trainingsEnabled)
        _runBootstrapRefresh(() => refreshTrainingsIfAllowed()),
      _runBootstrapRefresh(() => refreshTaskBoard()),
      if (canAccessTrainerBoard)
        _runBootstrapRefresh(() => refreshTrainerBoard()),
      if (canAccessSupervisorBoard)
        _runBootstrapRefresh(() => refreshSupervisorBoard()),
      if (_features.pointsEnabled) _runBootstrapRefresh(() => refreshPointCenter()),
      if (_features.dailyShiftReportsEnabled && canViewDailyShiftReports)
        _runBootstrapRefresh(() => refreshDailyShiftReports()),
    ]);
  }

  Future<void> initialize() async {
    if (isAuthenticated || _didAttemptBootstrapLogin) {
      return;
    }

    _didAttemptBootstrapLogin = true;
    isLoading = true;
    error = null;
    _stateChanged();

    try {
      await _hydrateSession(
        email: AppState._sharedSessionEmail,
        password: AppState._seedAccountPassword,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      _stateChanged();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    _stateChanged();

    try {
      await _hydrateSession(email: email, password: password);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      _stateChanged();
    }
  }

  Future<void> enterStudentManagerMode() async {
    await _hydrateSession(
      email: AppState._studentManagerEmail,
      password: AppState._seedAccountPassword,
    );
  }

  Future<void> restoreSharedSession() async {
    await _hydrateSession(
      email: AppState._sharedSessionEmail,
      password: AppState._seedAccountPassword,
    );
  }

  void logout() {
    // Reset every derived workflow branch so the next session always starts
    // from a clean state.
    user = null;
    _token = null;
    error = null;
    landingItems = const [];
    trainings = const [];
    todaysTraining = null;
    trainingDate = null;
    pointInbox = const [];
    pointSent = const [];
    pointApprovalQueue = const [];
    pointAssignableUsers = const [];
    pointInboxError = null;
    pointSentError = null;
    pointAssignableUsersError = null;
    pointApprovalQueueError = null;
    currentLineShiftReport = null;
    dailyShiftReports = const [];
    currentLineShiftReportError = null;
    dailyShiftReportsError = null;
    taskBoard = null;
    supervisorBoard = null;
    supervisorJobTaskBoard = null;
    supervisorSelectedJobId = null;
    supervisorPanelMode = 'Jobs';
    supervisorSecondaries = List<SecondaryJobItem>.from(
      AppState._defaultSupervisorSecondaries,
    );
    supervisorDeepCleanChecks = const {};
    trainerBoard = null;
    trainerTraineeCount = 1;
    trainerSelectedTraineeSlot = 0;
    trainerTraineeJobBySlot = const {0: null};
    trainerSlotTasks = const {};
    _didAttemptBootstrapLogin = false;
    _stateChanged();
  }
}
