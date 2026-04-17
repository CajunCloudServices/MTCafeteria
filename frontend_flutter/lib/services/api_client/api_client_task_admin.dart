part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientTaskAdmin on ApiClient {
  Map<String, String> _taskAdminHeaders(
    String token,
    String password, {
    bool json = false,
  }) {
    return {
      ..._authHeaders(token),
      'X-Task-Editor-Password': password,
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      if (json) 'Content-Type': 'application/json',
    };
  }

  Future<AdminTaskBoard> getTaskAdminBoard(String token, String password) async {
    final uri = Uri.parse(
      '$_baseUrl/api/task-admin/board',
    ).replace(queryParameters: {
      '_': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    final response = await _send(
      () => http.get(
        uri,
        headers: _taskAdminHeaders(token, password),
      ),
      'Failed to load job/task board',
    );
    if (response.statusCode != 200) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to load job/task board'),
        statusCode: response.statusCode,
      );
    }
    return AdminTaskBoard.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AdminJob> createAdminJob(
    String token,
    String password, {
    required String name,
    required int shiftId,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$_baseUrl/api/task-admin/jobs'),
        headers: _taskAdminHeaders(token, password, json: true),
        body: jsonEncode({'name': name, 'shiftId': shiftId}),
      ),
      'Failed to create job',
    );
    if (response.statusCode != 201) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to create job'),
        statusCode: response.statusCode,
      );
    }
    return AdminJob.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AdminJob> renameAdminJob(
    String token,
    String password, {
    required int jobId,
    required String name,
  }) async {
    final response = await _send(
      () => http.patch(
        Uri.parse('$_baseUrl/api/task-admin/jobs/$jobId'),
        headers: _taskAdminHeaders(token, password, json: true),
        body: jsonEncode({'name': name}),
      ),
      'Failed to rename job',
    );
    if (response.statusCode != 200) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to rename job'),
        statusCode: response.statusCode,
      );
    }
    return AdminJob.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteAdminJob(String token, String password, int jobId) async {
    final response = await _send(
      () => http.delete(
        Uri.parse('$_baseUrl/api/task-admin/jobs/$jobId'),
        headers: _taskAdminHeaders(token, password),
      ),
      'Failed to delete job',
    );
    if (response.statusCode != 204) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to delete job'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<AdminTask> createAdminTask(
    String token,
    String password, {
    required int jobId,
    required String description,
    required String phase,
    bool? requiresCheckoff,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$_baseUrl/api/task-admin/jobs/$jobId/tasks'),
        headers: _taskAdminHeaders(token, password, json: true),
        body: jsonEncode({
          'description': description,
          'phase': phase,
          'requiresCheckoff': ?requiresCheckoff,
        }),
      ),
      'Failed to create task',
    );
    if (response.statusCode != 201) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to create task'),
        statusCode: response.statusCode,
      );
    }
    return AdminTask.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AdminTask> updateAdminTask(
    String token,
    String password, {
    required int taskId,
    String? description,
    String? phase,
    bool? requiresCheckoff,
  }) async {
    final payload = <String, dynamic>{};
    if (description != null) payload['description'] = description;
    if (phase != null) payload['phase'] = phase;
    if (requiresCheckoff != null) payload['requiresCheckoff'] = requiresCheckoff;

    final response = await _send(
      () => http.patch(
        Uri.parse('$_baseUrl/api/task-admin/tasks/$taskId'),
        headers: _taskAdminHeaders(token, password, json: true),
        body: jsonEncode(payload),
      ),
      'Failed to update task',
    );
    if (response.statusCode != 200) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to update task'),
        statusCode: response.statusCode,
      );
    }
    return AdminTask.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteAdminTask(String token, String password, int taskId) async {
    final response = await _send(
      () => http.delete(
        Uri.parse('$_baseUrl/api/task-admin/tasks/$taskId'),
        headers: _taskAdminHeaders(token, password),
      ),
      'Failed to delete task',
    );
    if (response.statusCode != 204) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to delete task'),
        statusCode: response.statusCode,
      );
    }
  }
}
