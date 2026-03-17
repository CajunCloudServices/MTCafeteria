import 'package:flutter/foundation.dart';

import '../config/app_features.dart';
import '../config/runtime_config.dart';
import '../models/daily_shift_report.dart';
import '../models/landing_item.dart';
import '../models/point_assignment.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';
import '../services/api_client.dart';

/// Central application state for auth, task workflows, references, points, and
/// supervisor reporting.
///
/// The UI stays mostly declarative and pushes orchestration into this class so
/// the same role/feature rules apply consistently across pages.
class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient, AppRuntimeConfig? runtimeConfig})
    : _runtimeConfig = runtimeConfig ?? AppRuntimeConfig.fromEnvironment,
      _features = AppFeatures.fromRuntimeConfig(
        runtimeConfig ?? AppRuntimeConfig.fromEnvironment,
      ),
      _apiClient =
          apiClient ??
          ApiClient(
            runtimeConfig: runtimeConfig ?? AppRuntimeConfig.fromEnvironment,
          );

  static const List<SecondaryJobItem> _defaultSupervisorSecondaries = [
    SecondaryJobItem(
      name:
          'Put any empty meal rack in the custodial closet and empty the rack behind scullery if it is full',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Put dirty rags in laundry',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Restock gloves to have 2 of each kind in each location',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Restock hairnets so at least 2 bundles are in each location',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name:
          'Change trash in the entire kitchen and empty carts into compactors',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Complete deep cleaning assignment(s)',
      phase: 'While doors are open',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Wipe tables',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Center napkins and salt/pepper on each table',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Straighten chairs',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Vacuum',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Spot mop tile floors',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Deep clean all bars and clean underneath, including sweeping',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Clear drinks bar of all used cups',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name:
          'Clean beverage stations in Cafe West and island with clean rags and empty dirty rags',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Start a load of laundry',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Switch dirty laundry bags if full in the custodial closet',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Return and wash red sanitizer buckets',
      phase: 'After doors close',
      checked: false,
    ),
    SecondaryJobItem(
      name: 'Put away new, clean laundry from BYU Laundry',
      phase: 'After doors close',
      checked: false,
      meals: ['Breakfast'],
    ),
    SecondaryJobItem(
      name: 'Bathroom: refill and tidy up',
      phase: 'After doors close',
      checked: false,
      meals: ['Breakfast', 'Lunch'],
    ),
    SecondaryJobItem(
      name: 'Move clean uniform items to the basement',
      phase: 'After doors close',
      checked: false,
      meals: ['Lunch'],
    ),
    SecondaryJobItem(
      name: 'Check CO2 levels',
      phase: 'After doors close',
      checked: false,
      meals: ['Lunch'],
    ),
    SecondaryJobItem(
      name: 'Clean the bathrooms',
      phase: 'After doors close',
      checked: false,
      meals: ['Dinner'],
    ),
    SecondaryJobItem(
      name:
          'Make sure no paper towel dispensers are empty, including dish return',
      phase: 'After doors close',
      checked: false,
      meals: ['Dinner'],
    ),
    SecondaryJobItem(
      name: 'Switch out dirty mop-head bag in mop closet',
      phase: 'After doors close',
      checked: false,
      meals: ['Dinner'],
    ),
    SecondaryJobItem(
      name: 'Pull everything off of the red floors',
      phase: 'After doors close',
      checked: false,
      meals: ['Dinner'],
    ),
    SecondaryJobItem(
      name: 'Clean out food and dishes left in kitchen sinks',
      phase: 'After doors close',
      checked: false,
      meals: ['Dinner'],
    ),
  ];

  final AppRuntimeConfig _runtimeConfig;
  final AppFeatures _features;
  final ApiClient _apiClient;

  // Auth/session
  UserSession? user;
  String? _token;

  bool isLoading = false;
  String? error;

  // Landing + trainings
  List<LandingItem> landingItems = const [];
  List<Training> trainings = const [];
  Training? todaysTraining;
  String? trainingDate;

  // Points center
  List<PointAssignment> pointInbox = const [];
  List<PointAssignment> pointSent = const [];
  List<PointAssignment> pointApprovalQueue = const [];
  List<AssignableUser> pointAssignableUsers = const [];

  // Daily shift reports
  DailyShiftReport? currentLineShiftReport;
  List<DailyShiftReport> dailyShiftReports = const [];

  // Feature-specific errors (kept isolated)
  String? pointInboxError;
  String? pointSentError;
  String? pointAssignableUsersError;
  String? pointApprovalQueueError;
  String? currentLineShiftReportError;
  String? dailyShiftReportsError;

  // Role workflow/task boards
  TaskBoard? taskBoard;
  SupervisorBoard? supervisorBoard;
  SupervisorJobTaskBoard? supervisorJobTaskBoard;
  int? supervisorSelectedJobId;
  TrainerBoard? trainerBoard;
  int trainerTraineeCount = 1;
  int trainerSelectedTraineeSlot = 0;
  Map<int, int?> trainerTraineeJobBySlot = const {0: null};
  Map<int, List<TrainerTraineeTask>> trainerSlotTasks = const {};

  String supervisorPanelMode = 'Jobs';
  List<SecondaryJobItem> supervisorSecondaries = List<SecondaryJobItem>.from(
    _defaultSupervisorSecondaries,
  );
  Map<String, bool> supervisorDeepCleanChecks = const {};

  bool get isAuthenticated => user != null && _token != null;
  bool get canAccessSupervisorBoard =>
      user?.role == 'Supervisor' || user?.role == 'Student Manager';
  bool get canAccessTrainerBoard => user?.canAccessTrainerBoard ?? false;
  bool get canManagePoints => user?.canManagePoints ?? false;
  bool get canSubmitPointRequests => user?.canSubmitPointRequests ?? false;
  bool get canViewDailyShiftReports => user?.canViewDailyShiftReports ?? false;
  bool get isDevBypassEnabled => _runtimeConfig.devBypassEnabled;

  bool _didAttemptBootstrapLogin = false;

  /// Performs the initial auth bootstrap for pilot mode or dev bypass mode.
  Future<void> initialize() async {
    if (isAuthenticated || _didAttemptBootstrapLogin) {
      return;
    }

    // Pilot mode should enter directly with supervisor-level permissions
    // so shift workers can scan and use without a login prompt.
    if (_runtimeConfig.isPilotProfile) {
      _didAttemptBootstrapLogin = true;
      await login(
        _runtimeConfig.pilotAutoLoginEmail,
        _runtimeConfig.pilotAutoLoginPassword,
      );
      return;
    }

    if (isDevBypassEnabled) {
      _didAttemptBootstrapLogin = true;
      await login(
        _runtimeConfig.devBypassEmail,
        _runtimeConfig.devBypassPassword,
      );
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

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
      notifyListeners();
    }
  }

  Future<void> refreshPointCenter() async {
    if (!isAuthenticated || !_features.pointsEnabled) return;

    pointInboxError = null;
    pointSentError = null;
    pointAssignableUsersError = null;
    pointApprovalQueueError = null;

    try {
      pointInbox = await _apiClient.getPointAssignmentInbox(_token!);
    } catch (e) {
      pointInbox = const [];
      pointInboxError = 'Could not load point notifications.';
      debugPrint('Point inbox failed: $e');
    }

    // Each section loads independently so one endpoint failure does not blank
    // the rest of the point center.
    if (canSubmitPointRequests) {
      try {
        pointSent = await _apiClient.getPointAssignmentsSent(_token!);
      } catch (e) {
        pointSent = const [];
        pointSentError = 'Could not load recent assignments.';
        debugPrint('Point sent list failed: $e');
      }

      try {
        pointAssignableUsers = await _apiClient.getAssignableUsers(_token!);
      } catch (e) {
        pointAssignableUsers = const [];
        pointAssignableUsersError = 'Could not load assignable users.';
        debugPrint('Assignable users failed: $e');
      }
    } else {
      pointSent = const [];
      pointAssignableUsers = const [];
    }

    if (canManagePoints) {
      try {
        pointApprovalQueue = await _apiClient.getPointApprovalQueue(_token!);
      } catch (e) {
        pointApprovalQueue = const [];
        pointApprovalQueueError = 'Could not load manager approval queue.';
        debugPrint('Point approval queue failed: $e');
      }
    } else {
      pointApprovalQueue = const [];
    }

    notifyListeners();
  }

  Future<void> assignPoints({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  }) async {
    if (!isAuthenticated || !canSubmitPointRequests) return;

    await _apiClient.createPointAssignment(
      _token!,
      assignedToUserId: assignedToUserId,
      pointsDelta: pointsDelta,
      assignmentDate: assignmentDate,
      reason: reason,
      assignmentDescription: assignmentDescription,
    );

    await refreshPointCenter();
  }

  Future<void> acceptAssignedPoints({
    required int assignmentId,
    required String initials,
  }) async {
    if (!isAuthenticated) return;

    final result = await _apiClient.acceptPointAssignment(
      _token!,
      assignmentId: assignmentId,
      initials: initials,
    );

    user = user?.copyWith(points: result.updatedPoints);
    await refreshPointCenter();
  }

  Future<void> approvePointAssignment({required int assignmentId}) async {
    if (!isAuthenticated || !canManagePoints) return;

    await _apiClient.approvePointAssignment(
      _token!,
      assignmentId: assignmentId,
    );

    await refreshPointCenter();
  }

  Future<void> refreshLandingItems() async {
    if (!isAuthenticated) return;
    final data = await _apiClient.getLandingItems(_token!);
    landingItems = data;
    notifyListeners();
  }

  Future<void> refreshTrainingsIfAllowed() async {
    if (!isAuthenticated ||
        !_features.trainingsEnabled ||
        !(user?.canViewTrainings ?? false)) {
      trainings = const [];
      todaysTraining = null;
      trainingDate = null;
      notifyListeners();
      return;
    }

    final data = await _apiClient.getTrainings(_token!);
    trainings = data.trainings;
    todaysTraining = data.todaysTraining;
    trainingDate = data.today;
    notifyListeners();
  }

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
    notifyListeners();
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

  Future<void> refreshTrainerBoard({String? meal, List<int>? jobIds}) async {
    if (!isAuthenticated || !canAccessTrainerBoard) return;
    final board = await _apiClient.getTrainerBoard(
      _token!,
      meal: meal,
      jobIds: jobIds,
    );
    trainerBoard = board;
    await _reloadAllTrainerSlotTasks();
    notifyListeners();
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

    notifyListeners();
  }

  void selectTrainerTraineeSlot(int slot) {
    if (slot < 0 || slot >= trainerTraineeCount) return;
    trainerSelectedTraineeSlot = slot;
    notifyListeners();
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
      notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> _reloadAllTrainerSlotTasks() async {
    if (!isAuthenticated || trainerBoard == null) return;
    for (var slot = 0; slot < trainerTraineeCount; slot += 1) {
      final jobId = trainerTraineeJobBySlot[slot];
      if (jobId == null) continue;
      await setTrainerTraineeJob(slot: slot, jobId: jobId);
    }
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
    notifyListeners();
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
    if (!isAuthenticated ||
        !canAccessSupervisorBoard ||
        supervisorBoard == null) {
      return;
    }
    await _apiClient.resetSupervisorBoard(
      _token!,
      meal: supervisorBoard!.selectedMeal,
    );
    supervisorJobTaskBoard = null;
    supervisorSelectedJobId = null;
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
    notifyListeners();
  }

  void closeSupervisorJobTasks() {
    supervisorSelectedJobId = null;
    supervisorJobTaskBoard = null;
    notifyListeners();
  }

  void setSupervisorPanelMode(String mode) {
    supervisorPanelMode = mode;
    notifyListeners();
  }

  void toggleSecondaryJob(int index, bool checked) {
    supervisorSecondaries = [
      for (var i = 0; i < supervisorSecondaries.length; i += 1)
        i == index
            ? supervisorSecondaries[i].copyWith(checked: checked)
            : supervisorSecondaries[i],
    ];
    notifyListeners();
  }

  void resetSecondaryJobs() {
    supervisorSecondaries = [
      for (final item in supervisorSecondaries) item.copyWith(checked: false),
    ];
    supervisorDeepCleanChecks = const {};
    notifyListeners();
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
    notifyListeners();
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

    await _apiClient.setSupervisorTaskCheck(
      _token!,
      meal: supervisorBoard!.selectedMeal,
      jobId: supervisorSelectedJobId!,
      taskId: taskId,
      checked: checked,
    );

    // Refresh both the open detail view and the board summary so progress
    // counts stay in sync.
    await openSupervisorJobTasks(supervisorSelectedJobId!);
    await refreshSupervisorBoard(meal: supervisorBoard!.selectedMeal);
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

    await openSupervisorJobTasks(jobId);
    await refreshSupervisorBoard(meal: meal);
  }

  Future<void> loadCurrentLineShiftReport({String? meal}) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    final selectedMeal = meal ?? supervisorBoard?.selectedMeal ?? 'Breakfast';
    currentLineShiftReportError = null;

    try {
      currentLineShiftReport = await _apiClient.getCurrentDailyShiftReport(
        _token!,
        meal: selectedMeal,
      );
    } catch (e) {
      currentLineShiftReport = null;
      currentLineShiftReportError = 'Could not load daily shift report.';
      debugPrint('Daily shift report load failed: $e');
    }
    notifyListeners();
  }

  Future<void> saveCurrentLineShiftReportDraft({
    required String meal,
    required Map<String, String> payload,
  }) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    currentLineShiftReport = await _apiClient.saveDailyShiftReportDraft(
      _token!,
      meal: meal,
      payload: payload,
    );
    currentLineShiftReportError = null;
    notifyListeners();
  }

  Future<void> submitCurrentLineShiftReport({
    required String meal,
    required Map<String, String> payload,
  }) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    currentLineShiftReport = await _apiClient.submitDailyShiftReport(
      _token!,
      meal: meal,
      payload: payload,
    );
    currentLineShiftReportError = null;
    notifyListeners();
    if (_features.dailyShiftReportsEnabled && canViewDailyShiftReports) {
      await refreshDailyShiftReports();
    }
  }

  Future<void> refreshDailyShiftReports() async {
    if (!isAuthenticated ||
        !_features.dailyShiftReportsEnabled ||
        !canViewDailyShiftReports) {
      return;
    }
    dailyShiftReportsError = null;
    try {
      dailyShiftReports = await _apiClient.getDailyShiftReports(_token!);
    } catch (e) {
      dailyShiftReports = const [];
      dailyShiftReportsError = 'Could not load daily shift reports.';
      debugPrint('Daily shift reports list failed: $e');
    }
    notifyListeners();
  }

  Future<void> createLandingItem(Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.createLandingItem(_token!, payload);
    await refreshLandingItems();
  }

  Future<void> updateLandingItem(int id, Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.updateLandingItem(_token!, id, payload);
    await refreshLandingItems();
  }

  Future<void> deleteLandingItem(int id) async {
    if (!isAuthenticated) return;
    await _apiClient.deleteLandingItem(_token!, id);
    await refreshLandingItems();
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
      _defaultSupervisorSecondaries,
    );
    supervisorDeepCleanChecks = const {};
    trainerBoard = null;
    trainerTraineeCount = 1;
    trainerSelectedTraineeSlot = 0;
    trainerTraineeJobBySlot = const {0: null};
    trainerSlotTasks = const {};
    _didAttemptBootstrapLogin = false;
    notifyListeners();
  }
}
