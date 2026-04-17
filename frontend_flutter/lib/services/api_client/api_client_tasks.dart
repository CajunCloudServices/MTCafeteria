part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientTasks on ApiClient {
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

    final response = await _httpClient.get(uri, headers: _authHeaders(token));
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
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/task-board/tasks/$taskId/completion'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update task completion');
    }
  }

  Future<void> resetTaskFlow(
    String token, {
    required String meal,
    required int jobId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/task-board/reset-flow'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'meal': meal, 'jobId': jobId}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to reset task flow');
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

    final response = await _httpClient.get(uri, headers: _authHeaders(token));
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
    final response = await _httpClient.post(
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
}
