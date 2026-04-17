part of '../main.dart';

extension _MainShell on _MtcCafeteriaAppState {
  Widget _buildMainShellContent({
    required BuildContext context,
    required bool isLoggedIn,
    required UserSession? user,
    required bool canViewReference,
    required bool canOpenManagerPortal,
    required bool canViewTrainings,
    required bool canAssignPoints,
    required bool canViewDailyShiftReports,
    required _DashboardView effectiveDashboardView,
    required bool showTrackSelection,
    required bool showModeSelection,
    required List<String> availableTracks,
    required List<String> availableModes,
  }) {
    if (!isLoggedIn) {
      return LoginPage(
        isLoading: _state.isLoading,
        error: _state.error,
        onLogin: (email, password) async {
          await _state.login(email, password);
          if (_state.isAuthenticated && mounted) {
            _updateUi(() {
              _selectedIndex = 0;
              _resetDashboardSelectorsForRole(_state.user!.role);
            });
          }
        },
      );
    }

    if (_selectedIndex == 0) {
      return LandingPage(
        items: _state.landingItems,
        canManage: user!.canManageLanding && _adminModeEnabled,
        onCreate: (payload) => _state.createLandingItem(payload),
        onUpdate: (id, payload) => _state.updateLandingItem(id, payload),
        onDelete: (id) => _state.deleteLandingItem(id),
      );
    }

    if (_selectedIndex == 1) {
      return _buildDashboardContent(
        context: context,
        user: user,
        canViewReference: canViewReference,
        canOpenManagerPortal: canOpenManagerPortal,
        canViewTrainings: canViewTrainings,
        canAssignPoints: canAssignPoints,
        canViewDailyShiftReports: canViewDailyShiftReports,
        effectiveDashboardView: effectiveDashboardView,
        showTrackSelection: showTrackSelection,
        showModeSelection: showModeSelection,
        availableTracks: availableTracks,
        availableModes: availableModes,
      );
    }

    if (_selectedIndex == 2) {
      return ProfilePage(user: user!);
    }

    return LandingPage(
      items: _state.landingItems,
      canManage: user!.canManageLanding && _adminModeEnabled,
      onCreate: (payload) => _state.createLandingItem(payload),
      onUpdate: (id, payload) => _state.updateLandingItem(id, payload),
      onDelete: (id) => _state.deleteLandingItem(id),
    );
  }

  Widget _buildDashboardContent({
    required BuildContext context,
    required UserSession? user,
    required bool canViewReference,
    required bool canOpenManagerPortal,
    required bool canViewTrainings,
    required bool canAssignPoints,
    required bool canViewDailyShiftReports,
    required _DashboardView effectiveDashboardView,
    required bool showTrackSelection,
    required bool showModeSelection,
    required List<String> availableTracks,
    required List<String> availableModes,
  }) {
    if (effectiveDashboardView == _DashboardView.hub) {
      return DashboardHubCard(
        canOpenReference: canViewReference,
        canOpenFindItem: canViewReference,
        canOpenDiningMap: canViewReference,
        canViewTrainings: canViewTrainings,
        onOpenWorkflow: () {
          _updateUi(() {
            _dashboardView = _DashboardView.workflow;
          });
        },
        onOpenFindItem: () {
          if (!canViewReference) return;
          _updateUi(() {
            _dashboardView = _DashboardView.findItem;
          });
        },
        onOpenDiningMap: () {
          if (!canViewReference) return;
          _updateUi(() {
            _dashboardView = _DashboardView.diningMap;
          });
        },
        onOpenManagerPortal: () async {
          if (!_adminModeEnabled) {
            await _enableAdminMode(context);
            if (!_adminModeEnabled) return;
          }
          _updateUi(() {
            _dashboardView = _DashboardView.managerPortal;
          });
          _state.refreshPointCenter();
          _state.refreshDailyShiftReports();
        },
        onOpenTrainings: () {
          if (!canViewTrainings) return;
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TrainingDetailPage(
                navIndex: _selectedIndex,
                onSelectNav: _handleBottomNavTap,
              ),
            ),
          );
        },
        onOpenReference: () {
          if (!canViewReference) return;
          _updateUi(() {
            _dashboardView = _DashboardView.reference;
          });
        },
      );
    }

    if (effectiveDashboardView == _DashboardView.reference) {
      return ReferenceSheetsView(adminModeEnabled: _adminModeEnabled);
    }
    if (effectiveDashboardView == _DashboardView.findItem) {
      return ReferenceSheetsView(
        initialSection: 'Find an Item',
        lockSection: true,
        adminModeEnabled: _adminModeEnabled,
      );
    }
    if (effectiveDashboardView == _DashboardView.diningMap) {
      return ReferenceSheetsView(
        initialSection: 'Dining Map',
        lockSection: true,
        adminModeEnabled: _adminModeEnabled,
      );
    }
    if (effectiveDashboardView == _DashboardView.dailyShiftReports) {
      return DailyShiftReportsView(
        reports: _state.dailyShiftReports,
        error: _state.dailyShiftReportsError,
        onRefresh: _state.refreshDailyShiftReports,
      );
    }

    if (effectiveDashboardView == _DashboardView.workflow &&
        showTrackSelection) {
      return ShiftTrackSelectionCard(
        availableTracks: availableTracks,
        selectedTrack: _dashboardTrack,
        onTrackChanged: (track) => _updateUi(() => _dashboardTrack = track),
        onContinue: () {
          if (user == null) return;
          _updateUi(() {
            _applyTrackSelection(user.role, _dashboardTrack);
          });
        },
      );
    }

    if (effectiveDashboardView == _DashboardView.workflow &&
        showModeSelection) {
      return ShiftRoleSelectionCard(
        title: _dashboardTrack == 'Dishroom'
            ? 'Select Dishroom Role'
            : 'Select Role',
        availableModes: availableModes,
        selectedMode: _dashboardMode,
        onModeChanged: (mode) => _updateUi(() => _dashboardMode = mode),
        onContinue: () async {
          if (_modeRequiresAdmin(_dashboardTrack, _dashboardMode) &&
              !_adminModeEnabled) {
            await _enableAdminMode(context);
            if (!_adminModeEnabled) return;
          }
          _updateUi(() {
            _dashboardRoleConfirmed = true;
          });
          if (_dashboardTrack == 'Line' && _dashboardMode == 'Supervisor') {
            _state.refreshSupervisorBoard();
          }
        },
      );
    }

    return DashboardPage(
      user: user!,
      resetFlowSignal: _dashboardResetSignal,
      backSignal: _dashboardBackSignal,
      onBackAtWorkflowRoot: () {
        _updateUi(() {
          if (availableModes.length > 1) {
            _dashboardRoleConfirmed = false;
          } else {
            _dashboardTrackConfirmed = false;
            _dashboardRoleConfirmed = false;
          }
        });
      },
      onReturnToDashboardHub: () => _returnToDashboardHubAndReset(user.role),
      selectedTrack: effectiveDashboardView == _DashboardView.managerPortal
          ? 'Student Manager Portal'
          : effectiveDashboardView == _DashboardView.points
          ? 'Student Manager Portal'
          : _dashboardTrack,
      selectedMode: effectiveDashboardView == _DashboardView.managerPortal
          ? 'Student Manager'
          : effectiveDashboardView == _DashboardView.points
          ? 'Leadership'
          : _dashboardMode,
      trainings: _state.trainings,
      todaysTraining: _state.todaysTraining,
      trainingDate: _state.trainingDate,
      taskBoard: _state.taskBoard,
      trainerBoard: _state.trainerBoard,
      supervisorBoard: _state.supervisorBoard,
      supervisorJobTaskBoard: _state.supervisorJobTaskBoard,
      supervisorSelectedJobId: _state.supervisorSelectedJobId,
      supervisorPanelMode: _state.supervisorPanelMode,
      supervisorSecondaries: _state.supervisorSecondaries,
      supervisorDeepCleanChecked: _state.isSupervisorDeepCleanChecked,
      currentLineShiftReport: _state.currentLineShiftReport,
      onSelectMeal: (meal) => _state.selectMealKeepJob(meal),
      onSelectJob: (jobId) => _state.refreshTaskBoard(
        meal: _state.taskBoard?.selectedMeal,
        jobId: jobId,
      ),
      onTaskToggle: (taskId, completed) =>
          _state.setTaskCompletion(taskId: taskId, completed: completed),
      onReloadTaskBoard: () => _state.refreshTaskBoard(),
      onResetEmployeeFlow: (meal, jobId) =>
          _state.resetCurrentTaskFlow(meal: meal, jobId: jobId),
      onSelectTrainerMeal: (meal) => _state.refreshTrainerBoard(meal: meal),
      trainerTraineeCount: _state.trainerTraineeCount,
      trainerSelectedTraineeSlot: _state.trainerSelectedTraineeSlot,
      trainerTraineeJobBySlot: _state.trainerTraineeJobBySlot,
      trainerSlotTasks: _state.trainerSlotTasks,
      onSetTrainerTraineeCount: (count) => _state.setTrainerTraineeCount(count),
      onSetTrainerTraineeJob: (slot, jobId) =>
          _state.setTrainerTraineeJob(slot: slot, jobId: jobId),
      onSelectTrainerTraineeSlot: (slot) =>
          _state.selectTrainerTraineeSlot(slot),
      onTrainerSlotTaskToggle: (slot, taskId, completed) =>
          _state.setTrainerSlotTaskCompletion(
            slot: slot,
            taskId: taskId,
            completed: completed,
          ),
      onReloadTrainerBoard: () => _state.refreshTrainerBoard(),
      onResetLeadTrainerFlow: () => _state.resetTrainerFlow(),
      onSelectTrainerJobs: (jobIds) async {},
      onTrainerTaskToggle: (traineeUserId, taskId, completed) async {},
      onSelectSupervisorMeal: (meal) =>
          _state.refreshSupervisorBoard(meal: meal),
      onSupervisorOpenJob: (jobId) => _state.openSupervisorJobTasks(jobId),
      onSupervisorCloseJob: () => _state.closeSupervisorJobTasks(),
      onSupervisorTaskToggle: (taskId, checked) =>
          _state.setSupervisorTaskCheck(taskId: taskId, checked: checked),
      onSupervisorBulkTaskToggle: (taskIds, checked) => _state
          .setSupervisorTaskChecksBulk(taskIds: taskIds, checked: checked),
      onSupervisorPanelModeChanged: (mode) =>
          _state.setSupervisorPanelMode(mode),
      onSupervisorSecondaryToggle: (index, checked) =>
          _state.toggleSecondaryJob(index, checked),
      onSupervisorDeepCleanToggle: (checked) =>
          _state.toggleSupervisorDeepClean(checked),
      onSupervisorResetSecondaries: () => _state.resetSecondaryJobs(),
      onResetSupervisorChecks: () => _state.resetSupervisorChecks(),
      onReloadSupervisorBoard: () => _state.refreshSupervisorBoard(),
      onLoadCurrentLineShiftReport: (meal) =>
          _state.loadCurrentLineShiftReport(meal: meal),
      onSaveCurrentLineShiftReport: (meal, payload) =>
          _state.saveCurrentLineShiftReportDraft(meal: meal, payload: payload),
      onSubmitCurrentLineShiftReport: (meal, payload) =>
          _state.submitCurrentLineShiftReport(meal: meal, payload: payload),
      pendingAssignments: _state.pointInbox,
      pointSentAssignments: _state.pointSent,
      pointApprovalAssignments: _state.pointApprovalQueue,
      pointAssignableUsers: _state.pointAssignableUsers,
      landingItems: _state.landingItems,
      dailyShiftReports: _state.dailyShiftReports,
      pointInboxError: _state.pointInboxError,
      pointSentError: _state.pointSentError,
      pointAssignableUsersError: _state.pointAssignableUsersError,
      pointApprovalQueueError: _state.pointApprovalQueueError,
      dailyShiftReportsError: _state.dailyShiftReportsError,
      onAcceptPointAssignment: (assignmentId, initials) => _state
          .acceptAssignedPoints(assignmentId: assignmentId, initials: initials),
      onAssignPoints:
          ({
            required assignedToUserId,
            required pointsDelta,
            required assignmentDate,
            required reason,
            required assignmentDescription,
          }) => _state.assignPoints(
            assignedToUserId: assignedToUserId,
            pointsDelta: pointsDelta,
            assignmentDate: assignmentDate,
            reason: reason,
            assignmentDescription: assignmentDescription,
          ),
      onApprovePointAssignment: (assignmentId) =>
          _state.approvePointAssignment(assignmentId: assignmentId),
      onRefreshPointCenter: () => _state.refreshPointCenter(),
      onRefreshDailyShiftReports: () => _state.refreshDailyShiftReports(),
      onCreateAnnouncement: (payload) => _state.createLandingItem(payload),
      onUpdateAnnouncement: (id, payload) =>
          _state.updateLandingItem(id, payload),
      onDeleteAnnouncement: (id) => _state.deleteLandingItem(id),
      onOpenTaskEditor: () => _openTaskEditor(context),
      );
  }

  Widget? _buildBottomNav(bool isLoggedIn) {
    if (!isLoggedIn) return null;

    return AppBottomNav(
      currentIndex: _selectedIndex,
      onTap: _handleBottomNavTap,
    );
  }
}
