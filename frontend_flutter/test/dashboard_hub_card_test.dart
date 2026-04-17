import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/widgets/dashboard_hub_card.dart';

void main() {
  Future<void> pumpHubCard(
    WidgetTester tester, {
    bool canOpenManagerPortal = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHubCard(
            canOpenReference: true,
            canOpenFindItem: true,
            canOpenDiningMap: true,
            canViewTrainings: true,
            canOpenManagerPortal: canOpenManagerPortal,
            onOpenWorkflow: () {},
            onOpenFindItem: () {},
            onOpenDiningMap: () {},
            onOpenManagerPortal: () {},
            onOpenAppFeedback: () {},
            onOpenTrainings: () {},
            onOpenReference: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('student manager portal appears under trainings', (tester) async {
    await pumpHubCard(tester);

    expect(find.text('2-minute Trainings'), findsOneWidget);
    expect(find.text('Student Manager Portal'), findsOneWidget);
  });

  testWidgets('app feedback is visible without student manager portal', (
    tester,
  ) async {
    await pumpHubCard(tester, canOpenManagerPortal: false);

    expect(find.text('Student Manager Portal'), findsNothing);
    expect(find.text('App Feedback'), findsOneWidget);
  });
}
