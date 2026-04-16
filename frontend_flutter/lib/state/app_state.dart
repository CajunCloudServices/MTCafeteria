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

part 'app_state/auth.dart';
part 'app_state/points.dart';
part 'app_state/content.dart';
part 'app_state/tasks.dart';
part 'app_state/supervisor.dart';
part 'app_state/reports.dart';

/// Central application state for auth, task workflows, references, points, and
/// supervisor reporting.
///
/// The UI stays mostly declarative and pushes orchestration into this class so
/// the same role/feature rules apply consistently across pages.
class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient, AppRuntimeConfig? runtimeConfig})
    : _features = AppFeatures.fromRuntimeConfig(
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

  bool _didAttemptBootstrapLogin = false;

  void _stateChanged() {
    notifyListeners();
  }
}
