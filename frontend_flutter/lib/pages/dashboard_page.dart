import 'dart:async';

import 'package:flutter/material.dart';

import '../config/line_deep_clean_assignments.dart';
import '../models/daily_shift_report.dart';
import '../models/landing_item.dart';
import '../models/point_assignment.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/daily_shift_reports_view.dart';
import '../widgets/manager_portal_nav.dart';
import '../widgets/supervisor_daily_shift_report_form.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_chip.dart';
import '../widgets/ui/stitch_dropdown_field.dart';
import '../widgets/ui/stitch_list_row.dart';
import '../widgets/ui/stitch_selection_screen.dart';
import '../widgets/ui/stitch_task_widgets.dart';
import 'reference_sheets_view.dart';
import 'dashboard_support_sections.dart';
import 'landing_page.dart';
import 'reporting_page.dart';

part 'dashboard/manager_portal_section.dart';
part 'dashboard/employee_flow_section.dart';
part 'dashboard/lead_trainer_flow_section.dart';
part 'dashboard/lead_trainer_flow_helpers.dart';
part 'dashboard/flow_phase_checklists.dart';
part 'dashboard/supervisor_flow_section.dart';
part 'dashboard/supervisor_flow_helpers.dart';
part 'dashboard/supervisor_flow_views.dart';
part 'dashboard/job_notes_dialogs.dart';

Future<bool> _showShiftFinishPrompt(
  BuildContext context, {
  String title = 'Finished with this shift?',
  String message =
      'Everything is checked off. Are you ready to finish the shift now?',
  String confirmLabel = 'Yes, Finish Shift',
  String cancelLabel = 'Not Yet',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Main workflow page for line, supervisor, trainer, and support-track flows.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.resetFlowSignal,
    required this.backSignal,
    required this.onBackAtWorkflowRoot,
    required this.onReturnToDashboardHub,
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
    required this.onReloadTaskBoard,
    required this.onResetEmployeeFlow,
    required this.onSelectTrainerMeal,
    required this.trainerTraineeCount,
    required this.trainerSelectedTraineeSlot,
    required this.trainerTraineeJobBySlot,
    required this.trainerSlotTasks,
    required this.onSetTrainerTraineeCount,
    required this.onSetTrainerTraineeJob,
    required this.onSelectTrainerTraineeSlot,
    required this.onTrainerSlotTaskToggle,
    required this.onReloadTrainerBoard,
    required this.onResetLeadTrainerFlow,
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
    required this.landingItems,
    required this.dailyShiftReports,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.dailyShiftReportsError,
    required this.onAcceptPointAssignment,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
    required this.onRefreshDailyShiftReports,
    required this.onCreateAnnouncement,
    required this.onUpdateAnnouncement,
    required this.onDeleteAnnouncement,
    required this.onOpenTaskEditor,
    required this.managerPortalBack,
  });

  final UserSession user;
  final int resetFlowSignal;
  final int backSignal;
  final VoidCallback onBackAtWorkflowRoot;
  final Future<void> Function() onReturnToDashboardHub;
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
  final List<LandingItem> landingItems;
  final List<DailyShiftReport> dailyShiftReports;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final String? dailyShiftReportsError;

  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;
  final Future<void> Function() onReloadTaskBoard;
  final Future<void> Function(String meal, int jobId) onResetEmployeeFlow;
  final Future<void> Function(String meal) onSelectTrainerMeal;
  final ValueChanged<int> onSetTrainerTraineeCount;
  final Future<void> Function(int slot, int? jobId) onSetTrainerTraineeJob;
  final ValueChanged<int> onSelectTrainerTraineeSlot;
  final Future<void> Function(int slot, int taskId, bool completed)
  onTrainerSlotTaskToggle;
  final Future<void> Function() onReloadTrainerBoard;
  final VoidCallback onResetLeadTrainerFlow;
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
  final Future<void> Function() onRefreshDailyShiftReports;
  final Future<void> Function(Map<String, dynamic>) onCreateAnnouncement;
  final Future<void> Function(int id, Map<String, dynamic>) onUpdateAnnouncement;
  final Future<void> Function(int id) onDeleteAnnouncement;
  final Future<void> Function() onOpenTaskEditor;
  final ManagerPortalBackController managerPortalBack;

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
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
              onReturnToDashboardHub: onReturnToDashboardHub,
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
              onReloadBoard: onReloadTrainerBoard,
              onResetFlow: onResetLeadTrainerFlow,
            )
          else if (isLineTrack && isLineWorkerMode)
            _EmployeeTaskSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
              onReturnToDashboardHub: onReturnToDashboardHub,
              taskBoard: taskBoard,
              onSelectMeal: onSelectMeal,
              onSelectJob: onSelectJob,
              onTaskToggle: onTaskToggle,
              onReloadBoard: onReloadTaskBoard,
              onResetCompletedFlow: onResetEmployeeFlow,
            )
          else if (isLineTrack && isLineSupervisorMode)
            _SupervisorSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
              onReturnToDashboardHub: onReturnToDashboardHub,
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
            DishroomLeadTrainerSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
            )
          else if (isDishroomTrack)
            DishroomWorkerSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
            )
          else if (isKitchenTrack)
            KitchenJobsSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
            )
          else if (isNightCustodialTrack)
            NightCustodialSection(
              resetSignal: resetFlowSignal,
              backSignal: backSignal,
              onBackAtRoot: onBackAtWorkflowRoot,
            )
          else if (isManagerTrack)
            _StudentManagerPortalSection(
              user: user,
              landingItems: landingItems,
              dailyShiftReports: dailyShiftReports,
              pendingAssignments: pendingAssignments,
              pointSentAssignments: pointSentAssignments,
              pointApprovalAssignments: pointApprovalAssignments,
              pointAssignableUsers: pointAssignableUsers,
              pointInboxError: pointInboxError,
              pointSentError: pointSentError,
              pointAssignableUsersError: pointAssignableUsersError,
              pointApprovalQueueError: pointApprovalQueueError,
              dailyShiftReportsError: dailyShiftReportsError,
              onAcceptPointAssignment: onAcceptPointAssignment,
              onAssignPoints: onAssignPoints,
              onApprovePointAssignment: onApprovePointAssignment,
              onRefreshPointCenter: onRefreshPointCenter,
              onRefreshDailyShiftReports: onRefreshDailyShiftReports,
              onCreateAnnouncement: onCreateAnnouncement,
              onUpdateAnnouncement: onUpdateAnnouncement,
              onDeleteAnnouncement: onDeleteAnnouncement,
              onOpenTaskEditor: onOpenTaskEditor,
              backController: managerPortalBack,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
