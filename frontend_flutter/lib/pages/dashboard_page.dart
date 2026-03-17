import 'package:flutter/material.dart';

import '../models/daily_shift_report.dart';
import '../models/point_assignment.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';
import '../widgets/supervisor_daily_shift_report_form.dart';
import 'dashboard_support_sections.dart';
import 'reporting_page.dart';

/// Small job-specific notes surfaced from employee and supervisor flows.
const Map<String, List<String>> jobQuickReference = {
  'Condiments Prep': [
    'Rotational condiments are stored in locker 10.',
    'Place setup pans on the cold plate by the fruit stand on the island.',
    'Sauce/liquid condiments use 6 1/3 black pans.',
    'Other condiments can be prepped in shotgun pans set in ice.',
    'Grapes/Kiwis are in locker 9: rinse, prep, cover, and date.',
  ],
  'Condiments Host': [
    'Breakfast island layout includes fruit, yogurt/granola, and specialty condiments.',
    'Label yogurt flavor during prep so allergen signs can be posted.',
    'Use posted fruit-bar pan sizing (small pans do not fit in some slots).',
  ],
  'Aloha Plate': [
    'Macaroni salad uses a green scoop.',
    'Questions: talk to Tosh first.',
    'If Tosh is unavailable, talk to Jamie, Jared, or a full-time manager.',
  ],
  'Choices': [
    'Follow line-runner style setup/during/cleanup standards.',
    'For leftover handling, use the posted Choices leftovers sheet.',
    'Keep hot leftovers and cold toppings separated per posted notes.',
  ],
  'Sack Cashier': [
    'Follow meal-specific setup and cleanup differences (breakfast vs lunch).',
    'Use sign/open-close and register steps exactly as posted.',
  ],
  'Salads': [
    'Fruit/seasonal prep references include locker sourcing and shotgun-pan yields.',
    'Specialty salad bins are in locker 8 and should be relabeled onto wrapped prep pans.',
  ],
  'Desserts': [
    'Sunday breakfast and kitchen-job dessert references include locker pull and portioning standards.',
  ],
};

/// Shared modal used by the job-note buttons throughout the dashboard flows.
void showJobQuickReferenceDialog(
  BuildContext context, {
  required String jobName,
  required List<String> lines,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$jobName Reference'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in lines) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('- '),
                    Expanded(child: Text(line)),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Main workflow page for line, supervisor, trainer, and support-track flows.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.resetFlowSignal,
    required this.selectedTrack,
    required this.selectedMode,
    required this.trainings,
    required this.todaysTraining,
    required this.trainingDate,
    required this.taskBoard,
    required this.trainerBoard,
    required this.supervisorBoard,
    required this.supervisorJobTaskBoard,
    required this.supervisorSelectedJobId,
    required this.supervisorPanelMode,
    required this.supervisorSecondaries,
    required this.supervisorDeepCleanChecked,
    required this.currentLineShiftReport,
    required this.onSelectMeal,
    required this.onSelectJob,
    required this.onTaskToggle,
    required this.onSelectTrainerMeal,
    required this.trainerTraineeCount,
    required this.trainerSelectedTraineeSlot,
    required this.trainerTraineeJobBySlot,
    required this.trainerSlotTasks,
    required this.onSetTrainerTraineeCount,
    required this.onSetTrainerTraineeJob,
    required this.onSelectTrainerTraineeSlot,
    required this.onTrainerSlotTaskToggle,
    required this.onSelectTrainerJobs,
    required this.onTrainerTaskToggle,
    required this.onSelectSupervisorMeal,
    required this.onSupervisorOpenJob,
    required this.onSupervisorCloseJob,
    required this.onSupervisorTaskToggle,
    required this.onSupervisorBulkTaskToggle,
    required this.onSupervisorPanelModeChanged,
    required this.onSupervisorSecondaryToggle,
    required this.onSupervisorDeepCleanToggle,
    required this.onSupervisorResetSecondaries,
    required this.onResetSupervisorChecks,
    required this.onReloadSupervisorBoard,
    required this.onLoadCurrentLineShiftReport,
    required this.onSaveCurrentLineShiftReport,
    required this.onSubmitCurrentLineShiftReport,
    required this.pendingAssignments,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.onAcceptPointAssignment,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
  });

  final UserSession user;
  final int resetFlowSignal;
  final String selectedTrack;
  final String selectedMode;
  final List<Training> trainings;
  final Training? todaysTraining;
  final String? trainingDate;
  final TaskBoard? taskBoard;
  final TrainerBoard? trainerBoard;
  final int trainerTraineeCount;
  final int trainerSelectedTraineeSlot;
  final Map<int, int?> trainerTraineeJobBySlot;
  final Map<int, List<TrainerTraineeTask>> trainerSlotTasks;
  final SupervisorBoard? supervisorBoard;
  final SupervisorJobTaskBoard? supervisorJobTaskBoard;
  final int? supervisorSelectedJobId;
  final String supervisorPanelMode;
  final List<SecondaryJobItem> supervisorSecondaries;
  final bool supervisorDeepCleanChecked;
  final DailyShiftReport? currentLineShiftReport;
  final List<PointAssignment> pendingAssignments;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;

  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;
  final Future<void> Function(String meal) onSelectTrainerMeal;
  final ValueChanged<int> onSetTrainerTraineeCount;
  final Future<void> Function(int slot, int? jobId) onSetTrainerTraineeJob;
  final ValueChanged<int> onSelectTrainerTraineeSlot;
  final Future<void> Function(int slot, int taskId, bool completed)
  onTrainerSlotTaskToggle;
  final Future<void> Function(List<int> jobIds) onSelectTrainerJobs;
  final Future<void> Function(int traineeUserId, int taskId, bool completed)
  onTrainerTaskToggle;

  final Future<void> Function(String meal) onSelectSupervisorMeal;
  final Future<void> Function(int jobId) onSupervisorOpenJob;
  final VoidCallback onSupervisorCloseJob;
  final Future<void> Function(int taskId, bool checked) onSupervisorTaskToggle;
  final Future<void> Function(List<int> taskIds, bool checked)
  onSupervisorBulkTaskToggle;
  final ValueChanged<String> onSupervisorPanelModeChanged;
  final void Function(int index, bool checked) onSupervisorSecondaryToggle;
  final ValueChanged<bool> onSupervisorDeepCleanToggle;
  final VoidCallback onSupervisorResetSecondaries;
  final Future<void> Function() onResetSupervisorChecks;
  final Future<void> Function() onReloadSupervisorBoard;
  final Future<void> Function(String meal) onLoadCurrentLineShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSaveCurrentLineShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSubmitCurrentLineShiftReport;
  final Future<void> Function(int assignmentId, String initials)
  onAcceptPointAssignment;
  final Future<void> Function({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  })
  onAssignPoints;
  final Future<void> Function(int assignmentId) onApprovePointAssignment;
  final Future<void> Function() onRefreshPointCenter;

  @override
  Widget build(BuildContext context) {
    final isLineTrack = selectedTrack == 'Line';
    final isDishroomTrack = selectedTrack == 'Dishroom';
    final isKitchenTrack = selectedTrack == 'Kitchen Jobs';
    final isNightCustodialTrack = selectedTrack == 'Night Custodial';
    final isManagerTrack = selectedTrack == 'Student Manager Portal';

    final isLineWorkerMode = selectedMode == 'Employee';
    final isLineLeadTrainerMode = selectedMode == 'Lead Trainer';
    final isLineSupervisorMode = selectedMode == 'Supervisor';
    final isDishroomLeadTrainerMode = selectedMode == 'Dishroom Lead Trainer';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLineTrack && isLineLeadTrainerMode)
            _LeadTrainerTaskSection(
              resetSignal: resetFlowSignal,
              trainerBoard: trainerBoard,
              traineeCount: trainerTraineeCount,
              selectedTraineeSlot: trainerSelectedTraineeSlot,
              traineeJobBySlot: trainerTraineeJobBySlot,
              trainerSlotTasks: trainerSlotTasks,
              onSelectMeal: onSelectTrainerMeal,
              onSetTraineeCount: onSetTrainerTraineeCount,
              onAssignTraineeJob: onSetTrainerTraineeJob,
              onSelectTraineeSlot: onSelectTrainerTraineeSlot,
              onTaskToggle: onTrainerSlotTaskToggle,
            )
          else if (isLineTrack && isLineWorkerMode)
            _EmployeeTaskSection(
              resetSignal: resetFlowSignal,
              taskBoard: taskBoard,
              onSelectMeal: onSelectMeal,
              onSelectJob: onSelectJob,
              onTaskToggle: onTaskToggle,
            )
          else if (isLineTrack && isLineSupervisorMode)
            _SupervisorSection(
              resetSignal: resetFlowSignal,
              supervisorBoard: supervisorBoard,
              jobTaskBoard: supervisorJobTaskBoard,
              selectedJobId: supervisorSelectedJobId,
              panelMode: supervisorPanelMode,
              secondaries: supervisorSecondaries,
              deepCleanChecked: supervisorDeepCleanChecked,
              currentLineShiftReport: currentLineShiftReport,
              onSelectMeal: onSelectSupervisorMeal,
              onOpenJob: onSupervisorOpenJob,
              onBackToJobs: onSupervisorCloseJob,
              onToggleTask: onSupervisorTaskToggle,
              onBulkToggleTasks: onSupervisorBulkTaskToggle,
              onPanelModeChanged: onSupervisorPanelModeChanged,
              onSecondaryToggle: onSupervisorSecondaryToggle,
              onDeepCleanToggle: onSupervisorDeepCleanToggle,
              onResetSecondaries: onSupervisorResetSecondaries,
              onResetAll: onResetSupervisorChecks,
              onReloadBoard: onReloadSupervisorBoard,
              onLoadDailyShiftReport: onLoadCurrentLineShiftReport,
              onSaveDailyShiftReport: onSaveCurrentLineShiftReport,
              onSubmitDailyShiftReport: onSubmitCurrentLineShiftReport,
            )
          else if (isDishroomTrack && isDishroomLeadTrainerMode)
            DishroomLeadTrainerSection(resetSignal: resetFlowSignal)
          else if (isDishroomTrack)
            DishroomWorkerSection(resetSignal: resetFlowSignal)
          else if (isKitchenTrack)
            KitchenJobsSection(resetSignal: resetFlowSignal)
          else if (isNightCustodialTrack)
            NightCustodialSection(resetSignal: resetFlowSignal)
          else if (isManagerTrack)
            _StudentManagerPortalSection(
              user: user,
              pendingAssignments: pendingAssignments,
              pointSentAssignments: pointSentAssignments,
              pointApprovalAssignments: pointApprovalAssignments,
              pointAssignableUsers: pointAssignableUsers,
              pointInboxError: pointInboxError,
              pointSentError: pointSentError,
              pointAssignableUsersError: pointAssignableUsersError,
              pointApprovalQueueError: pointApprovalQueueError,
              onAcceptPointAssignment: onAcceptPointAssignment,
              onAssignPoints: onAssignPoints,
              onApprovePointAssignment: onApprovePointAssignment,
              onRefreshPointCenter: onRefreshPointCenter,
            )
          else
            const Text('Choose a shift area to continue.'),
        ],
      ),
    );
  }
}

/// Student manager tools surfaced inside the dashboard when enabled.
class _StudentManagerPortalSection extends StatelessWidget {
  const _StudentManagerPortalSection({
    required this.user,
    required this.pendingAssignments,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.onAcceptPointAssignment,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
  });

  final UserSession user;
  final List<PointAssignment> pendingAssignments;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final Future<void> Function(int assignmentId, String initials)
  onAcceptPointAssignment;
  final Future<void> Function({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  })
  onAssignPoints;
  final Future<void> Function(int assignmentId) onApprovePointAssignment;
  final Future<void> Function() onRefreshPointCenter;

  @override
  Widget build(BuildContext context) {
    if (!user.canSubmitPointRequests && !user.canManagePoints) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('You do not have point center access for this portal.'),
        ),
      );
    }

    return ReportingPage(
      user: user,
      pendingAssignments: pendingAssignments,
      onAcceptAssignment: onAcceptPointAssignment,
      onRefresh: onRefreshPointCenter,
      canSubmitPointRequests: user.canSubmitPointRequests,
      canApprovePointRequests: user.canManagePoints,
      pointSentAssignments: pointSentAssignments,
      pointApprovalAssignments: pointApprovalAssignments,
      pointAssignableUsers: pointAssignableUsers,
      pointInboxError: pointInboxError,
      pointSentError: pointSentError,
      pointAssignableUsersError: pointAssignableUsersError,
      pointApprovalQueueError: pointApprovalQueueError,
      onAssignPoints: onAssignPoints,
      onApprovePointAssignment: onApprovePointAssignment,
      onRefreshPointCenter: onRefreshPointCenter,
    );
  }
}

/// Step-based line worker flow for meal selection, job selection, and
/// checklist completion.
class _EmployeeTaskSection extends StatefulWidget {
  const _EmployeeTaskSection({
    required this.resetSignal,
    required this.taskBoard,
    required this.onSelectMeal,
    required this.onSelectJob,
    required this.onTaskToggle,
  });

  final int resetSignal;
  final TaskBoard? taskBoard;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;

  @override
  State<_EmployeeTaskSection> createState() => _EmployeeTaskSectionState();
}

class _EmployeeTaskSectionState extends State<_EmployeeTaskSection> {
  static const int _finalStep = 5;

  int _step = 0;
  String? _selectedMeal;
  int _lastResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _lastResetSignal = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant _EmployeeTaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastResetSignal) {
      _lastResetSignal = widget.resetSignal;
      setState(() {
        // Parent resets should return the employee flow to the first step.
        _step = 0;
        _isTransitioning = false;
      });
    }
  }

  int? _selectedJobId;
  bool _isTransitioning = false;

  bool _allCheckoffComplete(List<TaskChecklistItem> tasks) {
    final checkoffTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (checkoffTasks.isEmpty) return true;
    return checkoffTasks.every((t) => t.completed);
  }

  @override
  Widget build(BuildContext context) {
    final taskBoard = widget.taskBoard;
    if (taskBoard == null) {
      return const Text('Loading task board...');
    }

    _selectedMeal ??= taskBoard.selectedMeal;
    _selectedJobId ??= taskBoard.selectedJobId;

    // Preserve the chosen job across meal changes when the same job still
    // exists in the new meal.
    final selectedJobId = taskBoard.jobs.any((j) => j.id == _selectedJobId)
        ? _selectedJobId
        : (taskBoard.jobs.isNotEmpty ? taskBoard.jobs.first.id : null);
    String? selectedJobName;
    if (selectedJobId != null) {
      for (final job in taskBoard.jobs) {
        if (job.id == selectedJobId) {
          selectedJobName = job.name;
          break;
        }
      }
    }
    final selectedJobReference = selectedJobName == null
        ? null
        : jobQuickReference[selectedJobName];

    final setupTasks = taskBoard.tasks
        .where((t) => t.phase == 'Setup')
        .toList();
    final duringTasks = taskBoard.tasks
        .where((t) => t.phase == 'During Shift')
        .toList();
    final cleanupTasks = taskBoard.tasks
        .where((t) => t.phase == 'Cleanup')
        .toList();

    final setupComplete = _allCheckoffComplete(setupTasks);
    final cleanupComplete = _allCheckoffComplete(cleanupTasks);

    if (_step >= _finalStep) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Shift Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF103760),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                'All tasks complete. Report to your supervisor.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264D76),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelTitle(
                    icon: Icons.format_list_bulleted,
                    title: 'Shift Tasks',
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_step + 1) / _finalStep,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: const Color(0xFFE2ECF8),
                    color: const Color(0xFF1F5E9C),
                  ),
                  const SizedBox(height: 12),
                  if (_step == 0) ...[
                    const Text(
                      'Step 1 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Choose your meal to begin.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMeal,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: taskBoard.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: _isTransitioning
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _selectedMeal = value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isTransitioning
                            ? null
                            : () async {
                                final meal =
                                    _selectedMeal ?? taskBoard.selectedMeal;
                                setState(() => _isTransitioning = true);
                                await widget.onSelectMeal(meal);
                                if (!mounted) return;
                                setState(() {
                                  _selectedJobId =
                                      widget.taskBoard?.selectedJobId;
                                  _step = 1;
                                  _isTransitioning = false;
                                });
                              },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 1) ...[
                    const Text(
                      'Step 2 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Choose your assigned job.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedJobId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Job'),
                      items: taskBoard.jobs
                          .map(
                            (j) => DropdownMenuItem<int>(
                              value: j.id,
                              child: Text(j.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isTransitioning
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _selectedJobId = value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isTransitioning || selectedJobId == null
                            ? null
                            : () async {
                                setState(() => _isTransitioning = true);
                                await widget.onSelectJob(selectedJobId);
                                if (!mounted) return;
                                setState(() {
                                  _step = 2;
                                  _isTransitioning = false;
                                });
                              },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 2) ...[
                    const Text(
                      'Step 3 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Complete setup tasks.'),
                    if (selectedJobReference != null &&
                        selectedJobName != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => showJobQuickReferenceDialog(
                            context,
                            jobName: selectedJobName!,
                            lines: selectedJobReference,
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('View Notes'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'Setup (Before Doors Open)',
                      tasks: setupTasks,
                      onTaskToggle: widget.onTaskToggle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: setupComplete
                            ? () {
                                setState(() {
                                  _step = 3;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 3) ...[
                    const Text(
                      'Step 4 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Use these during-shift tasks as your guide.'),
                    if (selectedJobReference != null &&
                        selectedJobName != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => showJobQuickReferenceDialog(
                            context,
                            jobName: selectedJobName!,
                            lines: selectedJobReference,
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('View Notes'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'During Shift (Doors Open)',
                      tasks: duringTasks,
                      onTaskToggle: widget.onTaskToggle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _step = 4;
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 4) ...[
                    const Text(
                      'Step 5 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Complete cleanup tasks.'),
                    if (selectedJobReference != null &&
                        selectedJobName != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => showJobQuickReferenceDialog(
                            context,
                            jobName: selectedJobName!,
                            lines: selectedJobReference,
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('View Notes'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'Cleanup (After Doors Close)',
                      tasks: cleanupTasks,
                      onTaskToggle: widget.onTaskToggle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cleanupComplete
                            ? () {
                                setState(() {
                                  _step = 5;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Step 5 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(
                            0xFF1F5E9C,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        'Cleanup complete. Report to your supervisor.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF113A67),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lead trainer flow for assigning trainee jobs and checking off trainee tasks.
class _LeadTrainerTaskSection extends StatefulWidget {
  const _LeadTrainerTaskSection({
    required this.resetSignal,
    required this.trainerBoard,
    required this.traineeCount,
    required this.selectedTraineeSlot,
    required this.traineeJobBySlot,
    required this.trainerSlotTasks,
    required this.onSelectMeal,
    required this.onSetTraineeCount,
    required this.onAssignTraineeJob,
    required this.onSelectTraineeSlot,
    required this.onTaskToggle,
  });
  final int resetSignal;

  final TrainerBoard? trainerBoard;
  final int traineeCount;
  final int selectedTraineeSlot;
  final Map<int, int?> traineeJobBySlot;
  final Map<int, List<TrainerTraineeTask>> trainerSlotTasks;
  final Future<void> Function(String meal) onSelectMeal;
  final ValueChanged<int> onSetTraineeCount;
  final Future<void> Function(int slot, int? jobId) onAssignTraineeJob;
  final ValueChanged<int> onSelectTraineeSlot;
  final Future<void> Function(int slot, int taskId, bool completed)
  onTaskToggle;

  @override
  State<_LeadTrainerTaskSection> createState() =>
      _LeadTrainerTaskSectionState();
}

class _LeadTrainerTaskSectionState extends State<_LeadTrainerTaskSection> {
  int _step = 0;
  String? _selectedMeal;
  int? _selectedCount;
  Map<int, bool> _traineeCheckedOff = {};
  Map<String, bool> _leadTrainerEndShiftChecks = {};
  bool _shiftFinished = false;

  bool _allTraineeCheckoffsComplete(List<TrainerTraineeTask> tasks) {
    final checkoffTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (checkoffTasks.isEmpty) return false;
    return checkoffTasks.every((t) => t.completed);
  }

  int _lastResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _lastResetSignal = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant _LeadTrainerTaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastResetSignal) {
      _lastResetSignal = widget.resetSignal;
      setState(() {
        // Reset should discard trainee selections and completion state.
        _step = 0;
        _shiftFinished = false;
        _traineeCheckedOff = {};
        _leadTrainerEndShiftChecks = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerBoard = widget.trainerBoard;
    if (trainerBoard == null) {
      return const Text('Loading trainer board...');
    }

    _selectedMeal ??= trainerBoard.selectedMeal;
    _selectedCount ??= widget.traineeCount;

    final selectedSlot = widget.selectedTraineeSlot;
    final selectedTasks = widget.trainerSlotTasks[selectedSlot] ?? const [];

    _traineeCheckedOff = {
      for (var i = 0; i < widget.traineeCount; i += 1)
        i: _traineeCheckedOff[i] ?? false,
    };

    final selectedTraineeCompleted = _allTraineeCheckoffsComplete(
      selectedTasks,
    );
    final selectedTraineeCheckedOff = _traineeCheckedOff[selectedSlot] ?? false;
    final checkedOffCount = List.generate(
      widget.traineeCount,
      (slot) => _traineeCheckedOff[slot] ?? false,
    ).where((checked) => checked).length;

    final allTraineesCheckedOff = checkedOffCount == widget.traineeCount;

    final leadTrainerChecklistDone = leadTrainerEndShiftCheckoffItems.every(
      (item) => _leadTrainerEndShiftChecks[item] ?? false,
    );

    final allAssigned = List.generate(
      widget.traineeCount,
      (slot) => widget.traineeJobBySlot[slot] != null,
    ).every((assigned) => assigned);

    String jobLabelForSlot(int slot) {
      final jobId = widget.traineeJobBySlot[slot];
      if (jobId == null) return 'Unassigned';
      for (final job in trainerBoard.jobs) {
        if (job.id == jobId) return job.name;
      }
      return 'Unassigned';
    }

    if (_shiftFinished) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Shift Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF103760),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'All trainees checked off: $checkedOffCount/${widget.traineeCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264D76),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  'All trainees checked off. Submit your shift report and check in with your supervisor.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF113A67),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelTitle(
                    icon: Icons.groups,
                    title: 'Trainee Support Board',
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_step + 1) / 4,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: const Color(0xFFE2ECF8),
                    color: const Color(0xFF1F5E9C),
                  ),
                  const SizedBox(height: 12),
                  if (_step == 0) ...[
                    const Text(
                      'Step 1 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Choose the meal.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMeal,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: trainerBoard.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMeal = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final meal =
                              _selectedMeal ?? trainerBoard.selectedMeal;
                          await widget.onSelectMeal(meal);
                          if (!mounted) return;
                          setState(() {
                            _step = 1;
                            _shiftFinished = false;
                            _traineeCheckedOff = {
                              for (var i = 0; i < widget.traineeCount; i += 1)
                                i: false,
                            };
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 1) ...[
                    const Text(
                      'Step 2 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Choose trainee count.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCount,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Trainee Count',
                      ),
                      items: List.generate(12, (index) => index + 1)
                          .map(
                            (count) => DropdownMenuItem<int>(
                              value: count,
                              child: Text('$count'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCount = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final count = _selectedCount ?? widget.traineeCount;
                          widget.onSetTraineeCount(count);
                          setState(() {
                            _step = 2;
                            _shiftFinished = false;
                            _traineeCheckedOff = {
                              for (var i = 0; i < count; i += 1) i: false,
                            };
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 2) ...[
                    const Text(
                      'Step 3 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Assign each trainee a job.'),
                    const SizedBox(height: 8),
                    ...List.generate(widget.traineeCount, (slot) {
                      final jobId = widget.traineeJobBySlot[slot];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trainee ${slot + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: jobId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Job',
                              ),
                              items: trainerBoard.jobs
                                  .map(
                                    (job) => DropdownMenuItem<int>(
                                      value: job.id,
                                      child: Text(job.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                widget.onAssignTraineeJob(slot, value);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: allAssigned
                            ? () {
                                widget.onSelectTraineeSlot(0);
                                setState(() {
                                  _step = 3;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Step 4 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Choose a trainee to review tasks.'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF9FB6D3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trainee Selection',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: selectedSlot,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Trainee',
                            ),
                            items: List.generate(widget.traineeCount, (slot) {
                              return DropdownMenuItem<int>(
                                value: slot,
                                child: Text(
                                  'Trainee ${slot + 1}: ${jobLabelForSlot(slot)}',
                                ),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                widget.onSelectTraineeSlot(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (jobQuickReference.containsKey(
                      jobLabelForSlot(selectedSlot),
                    )) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => showJobQuickReferenceDialog(
                            context,
                            jobName: jobLabelForSlot(selectedSlot),
                            lines:
                                jobQuickReference[jobLabelForSlot(
                                  selectedSlot,
                                )]!,
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('View Job Notes'),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF9FB6D3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task Checklist',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          _TrainerPhaseChecklist(
                            phase: 'Setup (Before Doors Open)',
                            tasks: selectedTasks
                                .where((t) => t.phase == 'Setup')
                                .toList(),
                            slot: selectedSlot,
                            onToggle: widget.onTaskToggle,
                          ),
                          _TrainerPhaseChecklist(
                            phase: 'During Shift (Doors Open)',
                            tasks: selectedTasks
                                .where((t) => t.phase == 'During Shift')
                                .toList(),
                            slot: selectedSlot,
                            onToggle: widget.onTaskToggle,
                          ),
                          _TrainerPhaseChecklist(
                            phase: 'Cleanup (After Doors Close)',
                            tasks: selectedTasks
                                .where((t) => t.phase == 'Cleanup')
                                .toList(),
                            slot: selectedSlot,
                            onToggle: widget.onTaskToggle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF9FB6D3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Checkoff',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Progress: $checkedOffCount/${widget.traineeCount} checked off',
                            style: const TextStyle(
                              color: Color(0xFF32567F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  selectedTraineeCompleted &&
                                      !selectedTraineeCheckedOff
                                  ? () {
                                      setState(() {
                                        _traineeCheckedOff = {
                                          ..._traineeCheckedOff,
                                          selectedSlot: true,
                                        };
                                      });
                                    }
                                  : null,
                              child: Text(
                                selectedTraineeCheckedOff
                                    ? 'Checked Off'
                                    : 'Check Off Trainee',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF9FB6D3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lead Trainer End-of-Shift Checkoff',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ...leadTrainerEndShiftCheckoffItems.map(
                            (item) => CheckboxListTile(
                              dense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _leadTrainerEndShiftChecks[item] ?? false,
                              title: Text(item),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _leadTrainerEndShiftChecks = {
                                    ..._leadTrainerEndShiftChecks,
                                    item: value,
                                  };
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_step == 3 &&
            allTraineesCheckedOff &&
            leadTrainerChecklistDone &&
            !_shiftFinished) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _shiftFinished = true;
                });
              },
              child: const Text('Finish'),
            ),
          ),
        ],
      ],
    );
  }
}

/// Phase checklist used inside the lead trainer workflow.
class _TrainerPhaseChecklist extends StatelessWidget {
  const _TrainerPhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.slot,
    required this.onToggle,
  });

  final String phase;
  final List<TrainerTraineeTask> tasks;
  final int slot;
  final Future<void> Function(int slot, int taskId, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9FB6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('No tasks loaded for this section.'),
            )
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onToggle(slot, task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                      subtitle: const Text(
                        'Continuous during-shift responsibility',
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Shared employee phase checklist widget.
class _PhaseChecklist extends StatelessWidget {
  const _PhaseChecklist({
    required this.phase,
    required this.tasks,
    required this.onTaskToggle,
  });

  final String phase;
  final List<TaskChecklistItem> tasks;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9FB6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('No tasks loaded for this section.'),
            )
          else
            ...tasks.map(
              (task) => task.requiresCheckoff
                  ? CheckboxListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: task.completed,
                      title: Text(task.description),
                      onChanged: (value) {
                        if (value != null) {
                          onTaskToggle(task.taskId, value);
                        }
                      },
                    )
                  : ListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      leading: const Icon(Icons.remove, size: 18),
                      title: Text(task.description),
                      subtitle: const Text(
                        'Continuous during-shift responsibility',
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Supervisor workflow for job cleanup, secondaries, deep clean, and report
/// submission.
class _SupervisorSection extends StatefulWidget {
  const _SupervisorSection({
    required this.resetSignal,
    required this.supervisorBoard,
    required this.jobTaskBoard,
    required this.selectedJobId,
    required this.panelMode,
    required this.secondaries,
    required this.deepCleanChecked,
    required this.currentLineShiftReport,
    required this.onSelectMeal,
    required this.onOpenJob,
    required this.onBackToJobs,
    required this.onToggleTask,
    required this.onBulkToggleTasks,
    required this.onPanelModeChanged,
    required this.onSecondaryToggle,
    required this.onDeepCleanToggle,
    required this.onResetSecondaries,
    required this.onResetAll,
    required this.onReloadBoard,
    required this.onLoadDailyShiftReport,
    required this.onSaveDailyShiftReport,
    required this.onSubmitDailyShiftReport,
  });

  final int resetSignal;
  final SupervisorBoard? supervisorBoard;
  final SupervisorJobTaskBoard? jobTaskBoard;
  final int? selectedJobId;
  final String panelMode;
  final List<SecondaryJobItem> secondaries;
  final bool deepCleanChecked;
  final DailyShiftReport? currentLineShiftReport;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onOpenJob;
  final VoidCallback onBackToJobs;
  final Future<void> Function(int taskId, bool checked) onToggleTask;
  final Future<void> Function(List<int> taskIds, bool checked)
  onBulkToggleTasks;
  final ValueChanged<String> onPanelModeChanged;
  final void Function(int index, bool checked) onSecondaryToggle;
  final ValueChanged<bool> onDeepCleanToggle;
  final VoidCallback onResetSecondaries;
  final Future<void> Function() onResetAll;
  final Future<void> Function() onReloadBoard;
  final Future<void> Function(String meal) onLoadDailyShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSaveDailyShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSubmitDailyShiftReport;

  @override
  State<_SupervisorSection> createState() => _SupervisorSectionState();
}

class _SupervisorSectionState extends State<_SupervisorSection> {
  String? _selectedMeal;
  String _selectedView = 'Jobs';
  bool _mealLoaded = false;
  bool _shiftFinished = false;
  bool _markingAllJobTasks = false;
  Map<String, bool> _supervisorEndShiftChecks = {};
  int _lastResetSignal = 0;

  bool _canMarkShiftFinished({
    required bool hasPendingJobs,
    required bool allSecondariesChecked,
    required bool deepCleanChecked,
    required bool supervisorChecklistDone,
    required bool reportSubmitted,
  }) {
    // Finishing the shift is intentionally stricter than simply completing job
    // cleanup; supervisor secondaries, deep clean, checklist items, and the
    // report all have to be done first.
    return !hasPendingJobs &&
        allSecondariesChecked &&
        deepCleanChecked &&
        supervisorChecklistDone &&
        reportSubmitted;
  }

  @override
  void initState() {
    _lastResetSignal = widget.resetSignal;
    super.initState();
    if (widget.panelMode == 'Jobs' ||
        widget.panelMode == 'Secondaries' ||
        widget.panelMode == 'Deep Clean' ||
        widget.panelMode == 'Daily Shift Report') {
      _selectedView = widget.panelMode;
    }
  }

  @override
  void didUpdateWidget(covariant _SupervisorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastResetSignal) {
      _lastResetSignal = widget.resetSignal;
      setState(() {
        _mealLoaded = false;
        _shiftFinished = false;
        _selectedView = 'Jobs';
        _supervisorEndShiftChecks = {};
      });
      widget.onPanelModeChanged('Jobs');
      widget.onBackToJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final supervisorBoard = widget.supervisorBoard;
    if (supervisorBoard == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loading supervisor board...'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: widget.onReloadBoard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    _selectedMeal ??= supervisorBoard.selectedMeal;

    final secondarySource = widget.secondaries.isNotEmpty
        ? widget.secondaries
        : const [
            SecondaryJobItem(
              name: 'Wipe spills in dining area',
              phase: 'While doors are open',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Restock napkin stations',
              phase: 'While doors are open',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Trashes',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Spot Mop',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Wipe Tables',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Straighten Chairs',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Collect Red Buckets',
              phase: 'After doors close',
              checked: false,
            ),
          ];

    bool isDuringPhase(String phase) {
      final value = phase.trim().toLowerCase();
      return value == 'during shift' ||
          value == 'while doors are open' ||
          value.contains('during');
    }

    bool isCleanupPhase(String phase) {
      final value = phase.trim().toLowerCase();
      return value == 'cleanup' ||
          value == 'after doors close' ||
          value.contains('cleanup') ||
          value.contains('after');
    }

    final mealScopedEntries = secondarySource
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value.meals.isEmpty ||
              entry.value.meals.contains(supervisorBoard.selectedMeal),
        )
        .toList();

    final mealScopedSecondaries = mealScopedEntries
        .map((e) => e.value)
        .toList();

    final duringSecondaries = mealScopedEntries
        .where((entry) => isDuringPhase(entry.value.phase))
        .toList();
    final cleanupSecondaries = mealScopedEntries
        .where((entry) => isCleanupPhase(entry.value.phase))
        .toList();

    final pendingJobs = supervisorBoard.jobs
        .where((j) => !(j.totalCount > 0 && j.checkedCount >= j.totalCount))
        .toList();
    final completedJobs = supervisorBoard.jobs
        .where((j) => j.totalCount > 0 && j.checkedCount >= j.totalCount)
        .toList();
    final allSecondariesChecked = mealScopedSecondaries.every((s) => s.checked);
    final supervisorChecklistDone = supervisorEndShiftCheckoffItems.every(
      (item) => _supervisorEndShiftChecks[item] ?? false,
    );
    final report = widget.currentLineShiftReport;
    final reportSubmitted =
        report != null &&
        report.isSubmitted &&
        report.mealType == supervisorBoard.selectedMeal;

    final canMarkShiftFinished = _canMarkShiftFinished(
      hasPendingJobs: pendingJobs.isNotEmpty,
      allSecondariesChecked: allSecondariesChecked,
      deepCleanChecked: widget.deepCleanChecked,
      supervisorChecklistDone: supervisorChecklistDone,
      reportSubmitted: reportSubmitted,
    );

    if (_shiftFinished) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Shift Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF103760),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Jobs complete: ${completedJobs.length}/${supervisorBoard.jobs.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264D76),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secondaries complete: ${allSecondariesChecked ? 'Yes' : 'No'} • Deep clean complete: ${widget.deepCleanChecked ? 'Yes' : 'No'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264D76),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  'Shift complete. Submit your report and confirm handoff.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF113A67),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelTitle(
                    icon: Icons.task_alt,
                    title: 'Supervisor Checkoff',
                  ),
                  const SizedBox(height: 10),
                  if (!_mealLoaded) ...[
                    const Text('Choose meal to load tasks.'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMeal,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      isExpanded: true,
                      items: supervisorBoard.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMeal = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final meal =
                              _selectedMeal ?? supervisorBoard.selectedMeal;
                          final previousMeal = supervisorBoard.selectedMeal;
                          await widget.onSelectMeal(meal);
                          if (meal != previousMeal) {
                            await widget.onResetAll();
                            await widget.onSelectMeal(meal);
                          }
                          if (!mounted) return;
                          await widget.onLoadDailyShiftReport(meal);
                          if (!mounted) return;
                          setState(() {
                            _mealLoaded = true;
                            _shiftFinished = false;
                            _selectedView = 'Jobs';
                          });
                          widget.onPanelModeChanged('Jobs');
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Meal: ${supervisorBoard.selectedMeal}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedView,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: const [
                        DropdownMenuItem(value: 'Jobs', child: Text('Jobs')),
                        DropdownMenuItem(
                          value: 'Secondaries',
                          child: Text('Secondaries'),
                        ),
                        DropdownMenuItem(
                          value: 'Deep Clean',
                          child: Text('Deep Clean'),
                        ),
                        DropdownMenuItem(
                          value: 'Supervisor End-of-Shift',
                          child: Text('Supervisor End-of-Shift'),
                        ),
                        DropdownMenuItem(
                          value: 'Daily Shift Report',
                          child: Text('Daily Shift Report'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedView = value;
                          });
                          widget.onPanelModeChanged(value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_selectedView == 'Jobs') ...[
                      if (widget.selectedJobId != null) ...[
                        if (widget.jobTaskBoard == null)
                          const Text('Loading tasks...')
                        else ...[
                          Text(
                            widget.jobTaskBoard!.jobName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...widget.jobTaskBoard!.tasks.map(
                            (task) => CheckboxListTile(
                              dense: false,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: task.checked,
                              title: Text(task.description),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onToggleTask(task.taskId, value);
                                }
                              },
                            ),
                          ),
                          if (widget.jobTaskBoard!.tasks.any(
                            (task) => !task.checked,
                          )) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _markingAllJobTasks
                                    ? null
                                    : () async {
                                        final remainingTaskIds = widget
                                            .jobTaskBoard!
                                            .tasks
                                            .where((task) => !task.checked)
                                            .map((task) => task.taskId)
                                            .toList();
                                        if (remainingTaskIds.isEmpty) return;
                                        setState(() {
                                          _markingAllJobTasks = true;
                                        });
                                        try {
                                          await widget.onBulkToggleTasks(
                                            remainingTaskIds,
                                            true,
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _markingAllJobTasks = false;
                                            });
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.done_all_rounded),
                                label: Text(
                                  _markingAllJobTasks
                                      ? 'Marking Complete...'
                                      : 'Mark All as Complete',
                                ),
                              ),
                            ),
                          ],
                          if (jobQuickReference.containsKey(
                            widget.jobTaskBoard!.jobName,
                          )) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => showJobQuickReferenceDialog(
                                  context,
                                  jobName: widget.jobTaskBoard!.jobName,
                                  lines:
                                      jobQuickReference[widget
                                          .jobTaskBoard!
                                          .jobName]!,
                                ),
                                icon: const Icon(Icons.menu_book_rounded),
                                label: const Text('View Job Notes'),
                              ),
                            ),
                          ],
                        ],
                      ] else ...[
                        Text(
                          'Pending Jobs',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        if (pendingJobs.isEmpty)
                          const Text('No remaining jobs.')
                        else
                          ...pendingJobs.map(
                            (job) => ListTile(
                              dense: false,
                              tileColor: const Color(0xFFEAF4FF),
                              leading: const Icon(Icons.work_outline),
                              title: Text(job.jobName),
                              subtitle: Text(
                                '${job.checkedCount}/${job.totalCount} tasks checked',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => widget.onOpenJob(job.jobId),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          'Completed Jobs',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        if (completedJobs.isEmpty)
                          const Text('No completed jobs yet.')
                        else
                          ...completedJobs.map(
                            (job) => ListTile(
                              dense: false,
                              tileColor: const Color(0xFFDDEEE1),
                              leading: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF2E7D32),
                              ),
                              title: Text(job.jobName),
                              subtitle: Text(
                                '${job.checkedCount}/${job.totalCount} tasks checked',
                              ),
                            ),
                          ),
                      ],
                    ] else if (_selectedView == 'Secondaries') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFD0E3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'During Shift',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF123A65),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (duringSecondaries.isEmpty)
                              const Text('No tasks in this section.')
                            else
                              ...duringSecondaries.map(
                                (entry) => CheckboxListTile(
                                  dense: false,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  value: entry.value.checked,
                                  title: Text(entry.value.name),
                                  onChanged: (value) {
                                    if (value != null) {
                                      widget.onSecondaryToggle(
                                        entry.key,
                                        value,
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFD0E3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cleanup',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF123A65),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (cleanupSecondaries.isEmpty)
                              const Text('No tasks in this section.')
                            else
                              ...cleanupSecondaries.map(
                                (entry) => CheckboxListTile(
                                  dense: false,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  value: entry.value.checked,
                                  title: Text(entry.value.name),
                                  onChanged: (value) {
                                    if (value != null) {
                                      widget.onSecondaryToggle(
                                        entry.key,
                                        value,
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else if (_selectedView == 'Deep Clean') ...[
                      Text(
                        'Deep Clean • ${supervisorBoard.selectedMeal}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(weekdayNameLabel(DateTime.now().weekday)),
                      CheckboxListTile(
                        dense: false,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: widget.deepCleanChecked,
                        title: const Text('Deep Clean'),
                        onChanged: (value) {
                          if (value != null) {
                            widget.onDeepCleanToggle(value);
                          }
                        },
                      ),
                    ] else if (_selectedView == 'Supervisor End-of-Shift') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Supervisor End-of-Shift Checkoff',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            ...supervisorEndShiftCheckoffItems.map(
                              (item) => CheckboxListTile(
                                dense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: _supervisorEndShiftChecks[item] ?? false,
                                title: Text(item),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _supervisorEndShiftChecks = {
                                      ..._supervisorEndShiftChecks,
                                      item: value,
                                    };
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SupervisorDailyShiftReportForm(
                        key: ValueKey(
                          'daily-report-form-${supervisorBoard.selectedMeal}',
                        ),
                        meal: supervisorBoard.selectedMeal,
                        currentReport: widget.currentLineShiftReport,
                        onSave: widget.onSaveDailyShiftReport,
                        onSubmit: widget.onSubmitDailyShiftReport,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_mealLoaded &&
            _selectedView == 'Jobs' &&
            widget.selectedJobId != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onBackToJobs,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Jobs'),
            ),
          ),
        ],
        if (_mealLoaded &&
            _selectedView == 'Jobs' &&
            widget.selectedJobId == null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canMarkShiftFinished
                  ? () {
                      setState(() {
                        _shiftFinished = true;
                      });
                    }
                  : null,
              child: const Text('Mark Shift Finished'),
            ),
          ),
          if (_shiftFinished) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'Shift marked finished. You can still review jobs, secondaries, and deep clean.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF113A67),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
