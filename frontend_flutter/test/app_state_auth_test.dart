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
    'shared session boots as employee and manager unlock swaps report auth',
    () async {
      final reportAuthHeaders = <String?>[];

      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/login' && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final email = body['email'] as String;
          if (email == 'manager@mtc.local') {
            return http.Response(
              jsonEncode({
                'token': 'manager-token',
                'user': {
                  'id': 4,
                  'email': email,
                  'role': 'Student Manager',
                  'points': 6,
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (email == 'employee3@mtc.local') {
            return http.Response(
              jsonEncode({
                'token': 'employee-shared-token',
                'user': {
                  'id': 6,
                  'email': email,
                  'role': 'Employee',
                  'points': 5,
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('Unknown user', 404);
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

      expect(state.user?.role, 'Employee');
      expect(state.user?.points, 5);
      expect(state.authToken, 'employee-shared-token');
      expect(reportAuthHeaders, isEmpty);

      await state.enterStudentManagerMode();

      expect(state.user?.role, 'Student Manager');
      expect(state.authToken, 'manager-token');
      expect(reportAuthHeaders.last, 'Bearer manager-token');

      await state.restoreSharedSession();

      expect(state.user?.role, 'Employee');
      expect(state.user?.points, 5);
      expect(state.authToken, 'employee-shared-token');
      expect(reportAuthHeaders.last, 'Bearer manager-token');
    },
  );

  test('manager unlock still succeeds when a feature refresh fails', () async {
    var reportsCalls = 0;

    final client = MockClient((request) async {
      if (request.url.path == '/api/auth/login' && request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final email = body['email'] as String;
        if (email == 'manager@mtc.local') {
          return http.Response(
            jsonEncode({
              'token': 'manager-token',
              'user': {
                'id': 4,
                'email': email,
                'role': 'Student Manager',
                'points': 6,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (email == 'employee3@mtc.local') {
          return http.Response(
            jsonEncode({
              'token': 'employee-shared-token',
              'user': {
                'id': 6,
                'email': email,
                'role': 'Employee',
                'points': 5,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Unknown user', 404);
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
            'tasks': <Map<String, dynamic>>[],
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
            'jobs': <Map<String, dynamic>>[],
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
            'jobs': <Map<String, dynamic>>[],
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
        reportsCalls += 1;
        if (reportsCalls == 2) {
          return http.Response('boom', 500);
        }
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
    expect(state.user?.role, 'Employee');
    expect(state.authToken, 'employee-shared-token');

    await state.enterStudentManagerMode();
    expect(state.user?.role, 'Student Manager');
    expect(state.authToken, 'manager-token');
  });
}
