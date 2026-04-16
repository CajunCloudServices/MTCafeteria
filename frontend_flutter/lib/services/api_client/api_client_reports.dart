part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientReports on ApiClient {
  String _dailyShiftReportErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final missingFields = data['missingFields'];
        if (missingFields is List && missingFields.isNotEmpty) {
          return 'Missing required fields: ${missingFields.join(', ')}';
        }
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Fall back to a generic message when the response is not JSON.
    }
    return 'Failed to submit daily shift report (${response.statusCode})';
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
      body: jsonEncode({
        'meal': meal,
        'payload': payload,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_dailyShiftReportErrorMessage(response));
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
}
