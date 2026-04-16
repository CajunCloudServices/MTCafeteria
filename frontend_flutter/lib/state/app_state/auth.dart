part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateAuth on AppState {
  Future<void> initialize() async {
    if (isAuthenticated || _didAttemptBootstrapLogin) {
      return;
    }

    _didAttemptBootstrapLogin = true;
    isLoading = true;
    error = null;
    _stateChanged();

    try {
      // The deployed app now runs as a shared operational session. Boot the
      // same supervisor-capable session immediately instead of showing a
      // visible credential form with prefilled local passwords.
      _token = '';
      user = const UserSession(
        id: 0,
        email: 'shared-session@mtc.local',
        role: 'Supervisor',
        points: 0,
      );
      // Notify immediately so UI can switch off the boot/login screen and
      // render the authenticated shell while background data loads below.
      _stateChanged();

      await Future.wait([
        refreshLandingItems(),
        if (_features.trainingsEnabled) refreshTrainingsIfAllowed(),
        refreshTaskBoard(),
        if (canAccessTrainerBoard) refreshTrainerBoard(),
        if (canAccessSupervisorBoard) refreshSupervisorBoard(),
        if (_features.pointsEnabled) refreshPointCenter(),
        if (_features.dailyShiftReportsEnabled && canViewDailyShiftReports)
          refreshDailyShiftReports(),
      ]);
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
      final result = await _apiClient.login(email: email, password: password);
      _token = result.token;
      user = result.user;
      // Refresh only the feature areas that are actually enabled for the
      // current runtime profile so pilot builds do not depend on hidden
      // modules.
      await Future.wait([
        refreshLandingItems(),
        if (_features.trainingsEnabled) refreshTrainingsIfAllowed(),
        refreshTaskBoard(),
        if (canAccessTrainerBoard) refreshTrainerBoard(),
        if (canAccessSupervisorBoard) refreshSupervisorBoard(),
        if (_features.pointsEnabled) refreshPointCenter(),
        if (_features.dailyShiftReportsEnabled && canViewDailyShiftReports)
          refreshDailyShiftReports(),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      _stateChanged();
    }
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
