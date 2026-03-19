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

part 'api_client/api_client_auth.dart';
part 'api_client/api_client_content.dart';
part 'api_client/api_client_points.dart';
part 'api_client/api_client_reports.dart';
part 'api_client/api_client_supervisor.dart';
part 'api_client/api_client_tasks.dart';

class ApiClient {
  ApiClient({String? baseUrl, AppRuntimeConfig? runtimeConfig})
    : _baseUrl =
          (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : (runtimeConfig ?? AppRuntimeConfig.fromEnvironment).resolveApiBaseUrl(
              Uri.base,
            );

  final String _baseUrl;

  Map<String, String> _authHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, String> _jsonHeaders(String token) {
    return {..._authHeaders(token), 'Content-Type': 'application/json'};
  }
}
