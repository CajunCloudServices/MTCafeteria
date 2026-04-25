import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/models/task_board.dart';
import 'package:frontend_flutter/models/user_session.dart';
import 'package:frontend_flutter/pages/dashboard_page.dart';
import 'package:frontend_flutter/widgets/manager_portal_nav.dart';

void main() {
  final employeeUser = const UserSession(
    id: 1,
    email: 'employee@mtc.local',
    role: 'Employee',
    points: 0,
  );

  TaskBoard buildBoard() {
    return const TaskBoard(
      meals: ['Breakfast', 'Lunch', 'Dinner'],
      selectedMeal: 'Breakfast',
      jobs: [JobOption(id: 27, name: 'Beverages')],
      selectedJobId: 27,
      tasks: [
        TaskChecklistItem(
          taskId: 301,
          phase: 'Setup',
          description: 'Ensure all beverages are stocked',
          requiresCheckoff: true,
          completed: false,
        ),
        TaskChecklistItem(
          taskId: 302,
          phase: 'Setup',
          description: 'Turn on beverage machines',
          requiresCheckoff: true,
          completed: false,
        ),
        TaskChecklistItem(
          taskId: 303,
          phase: 'Setup',
          description: 'Check bib room',
          requiresCheckoff: true,
          completed: false,
        ),
      ],
    );
  }

  Future<void> pumpEmployeeDashboard(
    WidgetTester tester, {
    required Future<void> Function(int taskId, bool completed) onTaskToggle,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardPage(
            user: employeeUser,
            resetFlowSignal: 0,
            backSignal: 0,
            onBackAtWorkflowRoot: () {},
            onReturnToDashboardHub: () async {},
            selectedTrack: 'Line',
            selectedMode: 'Employee',
            trainings: const [],
            todaysTraining: null,
            trainingDate: null,
            taskBoard: buildBoard(),
            trainerBoard: null,
            supervisorBoard: null,
            supervisorJobTaskBoard: null,
            supervisorSelectedJobId: null,
            supervisorPanelMode: 'Jobs',
            supervisorSecondaries: const [],
            supervisorDeepCleanChecked: false,
            currentLineShiftReport: null,
            onSelectMeal: (meal) async {},
            onSelectJob: (jobId) async {},
            onTaskToggle: onTaskToggle,
            onReloadTaskBoard: () async {},
            onResetEmployeeFlow: (meal, jobId) async {},
            onSelectTrainerMeal: (meal) async {},
            trainerTraineeCount: 1,
            trainerSelectedTraineeSlot: 0,
            trainerTraineeJobBySlot: const {0: null},
            trainerSlotTasks: const {},
            onSetTrainerTraineeCount: (count) {},
            onSetTrainerTraineeJob: (slot, jobId) async {},
            onSelectTrainerTraineeSlot: (slot) {},
            onTrainerSlotTaskToggle: (slot, taskId, completed) async {},
            onReloadTrainerBoard: () async {},
            onResetLeadTrainerFlow: () {},
            onSelectTrainerJobs: (jobIds) async {},
            onTrainerTaskToggle: (traineeUserId, taskId, completed) async {},
            onSelectSupervisorMeal: (meal) async {},
            onSupervisorOpenJob: (jobId) async {},
            onSupervisorCloseJob: () {},
            onSupervisorTaskToggle: (taskId, completed) async {},
            onSupervisorBulkTaskToggle: (jobId, completed) async {},
            onSupervisorPanelModeChanged: (mode) {},
            onSupervisorSecondaryToggle: (name, checked) {},
            onSupervisorDeepCleanToggle: (checked) {},
            onSupervisorResetSecondaries: () {},
            onResetSupervisorChecks: () async {},
            onReloadSupervisorBoard: () async {},
            onLoadCurrentLineShiftReport: (meal) async {},
            onSaveCurrentLineShiftReport: (meal, report) async {},
            onSubmitCurrentLineShiftReport: (meal, report) async {},
            pendingAssignments: const [],
            pointSentAssignments: const [],
            pointApprovalAssignments: const [],
            pointAssignableUsers: const [],
            landingItems: const [],
            dailyShiftReports: const [],
            pointInboxError: null,
            pointSentError: null,
            pointAssignableUsersError: null,
            pointApprovalQueueError: null,
            dailyShiftReportsError: null,
            onAcceptPointAssignment: (assignmentId, accepted) async {},
            onAssignPoints:
                ({
                  required assignedToUserId,
                  required pointsDelta,
                  required assignmentDate,
                  required reason,
                  required assignmentDescription,
                }) async {},
            onApprovePointAssignment: (assignmentId) async {},
            onRefreshPointCenter: () async {},
            onRefreshDailyShiftReports: () async {},
            onCreateAnnouncement: (payload) async {},
            onUpdateAnnouncement: (id, payload) async {},
            onDeleteAnnouncement: (id) async {},
            onOpenTaskEditor: () async {},
            managerPortalBack: ManagerPortalBackController(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beverages'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'employee setup tasks check off immediately while async save runs',
    (tester) async {
      final completer = Completer<void>();
      await pumpEmployeeDashboard(
        tester,
        onTaskToggle: (taskId, completed) => completer.future,
      );

      expect(find.text('Setup'), findsOneWidget);

      await tester.tap(find.text('Start Service'));
      await tester.pumpAndSettle();
      expect(find.text('Setup'), findsOneWidget);

      await tester.tap(
        find.text('Ensure all beverages are stocked'),
      );
      await tester.pump();
      await tester.tap(find.text('Turn on beverage machines'));
      await tester.pump();
      await tester.tap(find.text('Check bib room'));
      await tester.pump();

      await tester.tap(find.text('Start Service'));
      await tester.pumpAndSettle();
      expect(find.text('Running'), findsOneWidget);

      completer.complete();
    },
  );

  testWidgets(
    'employee setup task rolls back and shows an error when save fails',
    (tester) async {
      await pumpEmployeeDashboard(
        tester,
        onTaskToggle: (taskId, completed) async {
          throw Exception('network failed');
        },
      );

      await tester.tap(
        find.text('Ensure all beverages are stocked'),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Could not update task. Please try again.'),
        findsOneWidget,
      );
    },
  );
}
