part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientPoints on ApiClient {
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
}
