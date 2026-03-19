part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientSupervisor on ApiClient {
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
}
