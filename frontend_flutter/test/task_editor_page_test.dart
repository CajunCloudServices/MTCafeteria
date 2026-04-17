import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/pages/task_editor_page.dart';
import 'package:frontend_flutter/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('task editor boot request includes bearer auth', (tester) async {
    late http.Request capturedRequest;

    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'shifts': [
            {
              'id': 1,
              'shiftType': 'Line',
              'mealType': 'Breakfast',
              'name': 'Breakfast Line',
            },
          ],
          'jobs': [
            {
              'id': 10,
              'shiftId': 1,
              'name': 'Beverages',
              'shiftName': 'Breakfast Line',
              'mealType': 'Breakfast',
              'tasks': {
                'Setup': [
                  {
                    'id': 100,
                    'jobId': 10,
                    'phase': 'Setup',
                    'description': 'Turn on beverage machines',
                    'requiresCheckoff': true,
                  },
                ],
              },
              'totalTaskCount': 1,
            },
          ],
          'phases': ['Setup', 'During Shift', 'Cleanup'],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: TaskEditorPage(
          authToken: 'jwt-token-123',
          apiClient: ApiClient(
            baseUrl: 'http://example.test',
            httpClient: client,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(capturedRequest.url.path, '/api/task-admin/board');
    expect(capturedRequest.headers['authorization'], 'Bearer jwt-token-123');
    expect(capturedRequest.headers.containsKey('x-task-editor-password'), isFalse);
    expect(find.text('Beverages'), findsOneWidget);
    expect(find.textContaining('1 jobs'), findsOneWidget);
  });

  testWidgets('task editor shows backend auth failures instead of blank state', (
    tester,
  ) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Authentication required.'}),
        401,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: TaskEditorPage(
          authToken: 'expired-or-missing-token',
          apiClient: ApiClient(
            baseUrl: 'http://example.test',
            httpClient: client,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Authentication required.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
