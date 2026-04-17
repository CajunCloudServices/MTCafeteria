import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/widgets/dashboard_hub_card.dart';

void main() {
  Future<void> pumpHubCard(
    WidgetTester tester, {
    required bool canOpenManagerPortal,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHubCard(
            canOpenReference: true,
            canOpenFindItem: true,
            canOpenDiningMap: true,
            canOpenManagerPortal: canOpenManagerPortal,
            canViewTrainings: true,
            onOpenWorkflow: () {},
            onOpenFindItem: () {},
            onOpenDiningMap: () {},
            onOpenManagerPortal: () {},
            onOpenTrainings: () {},
            onOpenReference: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('student manager portal stays hidden when access is disabled', (
    tester,
  ) async {
    await pumpHubCard(
      tester,
      canOpenManagerPortal: false,
    );

    expect(find.text('Student Manager Portal'), findsNothing);
  });

  testWidgets('student manager portal appears under trainings', (tester) async {
    await pumpHubCard(
      tester,
      canOpenManagerPortal: true,
    );

    expect(find.text('2-minute Trainings'), findsOneWidget);
    expect(find.text('Student Manager Portal'), findsOneWidget);
  });
}
