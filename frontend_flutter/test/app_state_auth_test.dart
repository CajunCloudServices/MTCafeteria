import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/config/runtime_config.dart';
import 'package:frontend_flutter/services/api_client.dart';
import 'package:frontend_flutter/state/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const runtimeConfig = AppRuntimeConfig(
    apiBaseUrl: 'http://example.test',
    appMode: 'test',
    featureManagerPortal: 'true',
    featureChatbot: 'false',
    featurePoints: 'false',
    featureDailyShiftReports: 'true',
    featureTrainings: 'false',
    featureReferences: 'true',
  );

  test(
    'shared session boots as supervisor and manager unlock swaps report auth',
    () async {
      final reportAuthHeaders = <String?>[];

      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/login' && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final email = body['email'] as String;
          final isManager = email == 'manager@mtc.local';
          return http.Response(
            jsonEncode({
              'token': isManager ? 'manager-token' : 'supervisor-token',
              'user': {
                'id': isManager ? 4 : 3,
                'email': email,
                'role': isManager ? 'Student Manager' : 'Supervisor',
                'points': isManager ? 6 : 9,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/content/landing-items') {
          return http.Response('[]', 200);
        }

        if (request.url.path == '/api/task-board') {
          return http.Response(
            jsonEncode({
              'meals': ['Breakfast', 'Lunch', 'Dinner'],
              'selectedMeal': 'Breakfast',
              'jobs': [
                {'id': 27, 'name': 'Beverages'},
              ],
              'selectedJobId': 27,
              'tasks': [
                {
                  'taskId': 301,
                  'phase': 'Setup',
                  'description': 'Turn on beverage machines',
                  'requiresCheckoff': true,
                  'completed': false,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/supervisor-board') {
          return http.Response(
            jsonEncode({
              'meals': ['Breakfast', 'Lunch', 'Dinner'],
              'selectedMeal': 'Breakfast',
              'jobs': [
                {
                  'jobId': 27,
                  'jobName': 'Beverages',
                  'checked': false,
                  'checkedCount': 0,
                  'totalCount': 1,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/trainer-board') {
          return http.Response(
            jsonEncode({
              'meals': ['Breakfast', 'Lunch', 'Dinner'],
              'selectedMeal': 'Breakfast',
              'jobs': [
                {'id': 27, 'name': 'Beverages'},
              ],
              'selectedJobIds': <int>[],
              'trainees': <Map<String, dynamic>>[],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/daily-shift-reports/current') {
          return http.Response(
            jsonEncode({'report': null}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/daily-shift-reports') {
          reportAuthHeaders.add(request.headers['authorization']);
          return http.Response('[]', 200);
        }

        return http.Response('Not found', 404);
      });

      final state = AppState(
        apiClient: ApiClient(
          baseUrl: 'http://example.test',
          httpClient: client,
        ),
        runtimeConfig: runtimeConfig,
      );

      await state.initialize();

      expect(state.user?.role, 'Supervisor');
      expect(state.authToken, 'supervisor-token');
      expect(reportAuthHeaders.last, 'Bearer supervisor-token');

      await state.enterStudentManagerMode();

      expect(state.user?.role, 'Student Manager');
      expect(state.authToken, 'manager-token');
      expect(reportAuthHeaders.last, 'Bearer manager-token');

      await state.restoreSharedSession();

      expect(state.user?.role, 'Supervisor');
      expect(state.authToken, 'supervisor-token');
      expect(reportAuthHeaders.last, 'Bearer supervisor-token');
    },
  );
}
