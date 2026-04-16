import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/models/task_board.dart';
import 'package:frontend_flutter/models/user_session.dart';
import 'package:frontend_flutter/pages/dashboard_page.dart';

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
            onSelectMeal: (_) async {},
            onSelectJob: (_) async {},
            onTaskToggle: onTaskToggle,
            onResetEmployeeFlow: (_, __) async {},
            onSelectTrainerMeal: (_) async {},
            trainerTraineeCount: 1,
            trainerSelectedTraineeSlot: 0,
            trainerTraineeJobBySlot: const {0: null},
            trainerSlotTasks: const {},
            onSetTrainerTraineeCount: (_) {},
            onSetTrainerTraineeJob: (_, __) async {},
            onSelectTrainerTraineeSlot: (_) {},
            onTrainerSlotTaskToggle: (_, __, ___) async {},
            onResetLeadTrainerFlow: () {},
            onSelectTrainerJobs: (_) async {},
            onTrainerTaskToggle: (_, __, ___) async {},
            onSelectSupervisorMeal: (_) async {},
            onSupervisorOpenJob: (_) async {},
            onSupervisorCloseJob: () {},
            onSupervisorTaskToggle: (_, __) async {},
            onSupervisorBulkTaskToggle: (_, __) async {},
            onSupervisorPanelModeChanged: (_) {},
            onSupervisorSecondaryToggle: (_, __) {},
            onSupervisorDeepCleanToggle: (_) {},
            onSupervisorResetSecondaries: () {},
            onResetSupervisorChecks: () async {},
            onReloadSupervisorBoard: () async {},
            onLoadCurrentLineShiftReport: (_) async {},
            onSaveCurrentLineShiftReport: (_, __) async {},
            onSubmitCurrentLineShiftReport: (_, __) async {},
            pendingAssignments: const [],
            pointSentAssignments: const [],
            pointApprovalAssignments: const [],
            pointAssignableUsers: const [],
            pointInboxError: null,
            pointSentError: null,
            pointAssignableUsersError: null,
            pointApprovalQueueError: null,
            onAcceptPointAssignment: (_, __) async {},
            onAssignPoints: ({
              required assignedToUserId,
              required pointsDelta,
              required assignmentDate,
              required reason,
              required assignmentDescription,
            }) async {},
            onApprovePointAssignment: (_) async {},
            onRefreshPointCenter: () async {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }

  testWidgets('employee setup tasks check off immediately while async save runs', (
    tester,
  ) async {
    final completer = Completer<void>();
    await pumpEmployeeDashboard(
      tester,
      onTaskToggle: (_, __) => completer.future,
    );

    expect(find.text('Step 3 of 5'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next')).onPressed,
      isNull,
    );

    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Ensure all beverages are stocked'),
    );
    await tester.pump();
    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Turn on beverage machines'),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Check bib room'));
    await tester.pump();

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(checkboxes, hasLength(3));
    expect(checkboxes.every((checkbox) => checkbox.value ?? false), isTrue);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next')).onPressed,
      isNotNull,
    );

    completer.complete();
  });

  testWidgets('employee setup task rolls back and shows an error when save fails', (
    tester,
  ) async {
    await pumpEmployeeDashboard(
      tester,
      onTaskToggle: (_, __) async {
        throw Exception('network failed');
      },
    );

    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Ensure all beverages are stocked'),
    );
    await tester.pump();
    await tester.pump();

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(checkboxes.first.value, isFalse);
    expect(find.text('Could not update task. Please try again.'), findsOneWidget);
  });
}
