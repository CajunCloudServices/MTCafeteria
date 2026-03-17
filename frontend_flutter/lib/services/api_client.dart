import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/runtime_config.dart';
import '../models/daily_shift_report.dart';
import '../models/landing_item.dart';
import '../models/point_assignment.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';

/// Thin HTTP client for the Flutter web frontend.
///
/// This class intentionally stays close to the REST surface: it sends requests,
/// validates status codes, and maps JSON into frontend models.
class ApiClient {
  ApiClient({String? baseUrl, AppRuntimeConfig? runtimeConfig})
    : _runtimeConfig = runtimeConfig ?? AppRuntimeConfig.fromEnvironment,
      _baseUrl =
          baseUrl ??
          (runtimeConfig ?? AppRuntimeConfig.fromEnvironment).resolveApiBaseUrl(
            Uri.base,
          );

  final AppRuntimeConfig _runtimeConfig;
  final String _baseUrl;

  String get baseUrl => _baseUrl;
  AppRuntimeConfig get runtimeConfig => _runtimeConfig;

  /// Creates a session token plus the minimal user payload needed by the app.
  Future<({String token, UserSession user})> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;

    return (
      token: data['token'] as String,
      user: UserSession(
        id: userJson['id'] as int,
        email: userJson['email'] as String,
        role: userJson['role'] as String,
        points: userJson['points'] as int? ?? 0,
      ),
    );
  }

  Future<List<LandingItem>> getLandingItems(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch landing items');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => LandingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LandingItem> createLandingItem(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<LandingItem> updateLandingItem(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteLandingItem(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete landing item');
    }
  }

  Future<({String today, List<Training> trainings, Training? todaysTraining})>
  getTrainings(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/trainings'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trainings');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final trainings = (data['trainings'] as List<dynamic>)
        .map((e) => Training.fromJson(e as Map<String, dynamic>))
        .toList();

    // The backend returns both the full list and the currently highlighted
    // training so the UI can render either a full browser or a compact today
    // panel from the same payload.
    final todaysTrainingJson = data['todaysTraining'];
    return (
      today: data['today'] as String,
      trainings: trainings,
      todaysTraining: todaysTrainingJson == null
          ? null
          : Training.fromJson(todaysTrainingJson as Map<String, dynamic>),
    );
  }

  Future<TaskBoard> getTaskBoard(
    String token, {
    String? meal,
    int? jobId,
    String? preferredJobName,
  }) async {
    // The task-board endpoint accepts either an explicit job id or a
    // preferred job name so the frontend can preserve selection across meals.
    final params = <String, String>{};
    if (meal != null) params['meal'] = meal;
    if (jobId != null) params['jobId'] = '$jobId';
    if (preferredJobName != null && preferredJobName.isNotEmpty) {
      params['preferredJobName'] = preferredJobName;
    }

    final uri = Uri.parse(
      '$_baseUrl/api/task-board',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch task board');
    }

    return TaskBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setTaskCompletion(
    String token, {
    required int taskId,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/task-board/tasks/$taskId/completion'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update task completion');
    }
  }

  Future<SupervisorBoard> getSupervisorBoard(
    String token, {
    String? meal,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/supervisor-board',
    ).replace(queryParameters: meal == null ? null : {'meal': meal});

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch supervisor board');
    }

    return SupervisorBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setSupervisorJobCheck(
    String token, {
    required String meal,
    required int jobId,
    required bool checked,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/supervisor-board/jobs/$jobId/check'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'checked': checked}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update supervisor checkoff');
    }
  }

  Future<void> resetSupervisorBoard(
    String token, {
    required String meal,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/supervisor-board/reset'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to reset supervisor board');
    }
  }

  Future<SupervisorJobTaskBoard> getSupervisorJobTasks(
    String token, {
    required String meal,
    required int jobId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/supervisor-board/jobs/$jobId/tasks',
    ).replace(queryParameters: {'meal': meal});

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch supervisor job tasks');
    }

    return SupervisorJobTaskBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setSupervisorTaskCheck(
    String token, {
    required String meal,
    required int jobId,
    required int taskId,
    required bool checked,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/supervisor-board/jobs/$jobId/tasks/$taskId/check',
      ),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'checked': checked}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update supervisor task check');
    }
  }

  Future<TrainerBoard> getTrainerBoard(
    String token, {
    String? meal,
    List<int>? jobIds,
  }) async {
    final params = <String, String>{};
    if (meal != null) params['meal'] = meal;
    if (jobIds != null) {
      params['jobIds'] = jobIds.join(',');
    }

    final uri = Uri.parse(
      '$_baseUrl/api/trainer-board',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trainer board');
    }

    return TrainerBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> setTrainerTraineeTaskCompletion(
    String token, {
    required int traineeUserId,
    required int taskId,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/trainer-board/trainees/$traineeUserId/tasks/$taskId/completion',
      ),
      headers: _jsonHeaders(token),
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update trainee task completion');
    }
  }

  Future<List<AssignableUser>> getAssignableUsers(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/points/assignable-users'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch assignable users');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => AssignableUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PointAssignment> createPointAssignment(
    String token, {
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/points/assignments'),
      headers: _jsonHeaders(token),
      body: jsonEncode({
        'assignedToUserId': assignedToUserId,
        'pointsDelta': pointsDelta,
        'assignmentDate': assignmentDate,
        'reason': reason,
        'assignmentDescription': assignmentDescription,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create point assignment (${response.statusCode})',
      );
    }

    return PointAssignment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<PointAssignment>> getPointAssignmentInbox(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/points/assignments/inbox'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch point inbox');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => PointAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PointAssignment>> getPointAssignmentsSent(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/points/assignments/sent'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch sent point assignments');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => PointAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PointAssignment>> getPointApprovalQueue(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/points/assignments/approval-queue'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch point approval queue');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => PointAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PointAssignment> approvePointAssignment(
    String token, {
    required int assignmentId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/points/assignments/$assignmentId/approve'),
      headers: _jsonHeaders(token),
      body: jsonEncode({}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to approve point assignment (${response.statusCode})',
      );
    }

    return PointAssignment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<PointAcceptResult> acceptPointAssignment(
    String token, {
    required int assignmentId,
    required String initials,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/points/assignments/$assignmentId/accept'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'initials': initials}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to accept point assignment (${response.statusCode})',
      );
    }

    return PointAcceptResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<DailyShiftReport?> getCurrentDailyShiftReport(
    String token, {
    required String meal,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/daily-shift-reports/current',
    ).replace(queryParameters: {'meal': meal});

    final response = await http.get(uri, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch daily shift report');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    // The endpoint returns `null` when a meal has no draft/submission yet.
    final reportJson = data['report'];
    if (reportJson == null) return null;
    return DailyShiftReport.fromJson(reportJson as Map<String, dynamic>);
  }

  Future<DailyShiftReport> saveDailyShiftReportDraft(
    String token, {
    required String meal,
    required Map<String, String> payload,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/daily-shift-reports/current'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'payload': payload}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save daily shift report draft');
    }

    return DailyShiftReport.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<DailyShiftReport> submitDailyShiftReport(
    String token, {
    required String meal,
    required Map<String, String> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/daily-shift-reports/current/submit'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'payload': payload}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit daily shift report');
    }

    return DailyShiftReport.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<DailyShiftReport>> getDailyShiftReports(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/daily-shift-reports'),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch daily shift reports');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => DailyShiftReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, String> _authHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  /// JSON endpoints all share the same auth + content-type header set.
  Map<String, String> _jsonHeaders(String token) {
    return {..._authHeaders(token), 'Content-Type': 'application/json'};
  }
}
