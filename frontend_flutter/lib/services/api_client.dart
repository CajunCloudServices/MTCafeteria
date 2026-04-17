import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/runtime_config.dart';
import '../models/admin_task_board.dart';
import '../models/chatbot.dart';
import '../models/daily_shift_report.dart';
import '../models/landing_item.dart';
import '../models/point_assignment.dart';
import '../models/supervisor_board.dart';
import '../models/task_board.dart';
import '../models/trainer_board.dart';
import '../models/training.dart';
import '../models/user_session.dart';

part 'api_client/api_client_auth.dart';
part 'api_client/api_client_chatbot.dart';
part 'api_client/api_client_content.dart';
part 'api_client/api_client_points.dart';
part 'api_client/api_client_reports.dart';
part 'api_client/api_client_supervisor.dart';
part 'api_client/api_client_task_admin.dart';
part 'api_client/api_client_tasks.dart';

/// Thrown when an HTTP call to the backend returns a non-success status.
///
/// Callers can inspect [statusCode] and [message] to surface a user-friendly
/// error without having to re-parse the backend's JSON envelope.
class ApiClientException implements Exception {
  ApiClientException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'ApiClientException: $message'
      : 'ApiClientException($statusCode): $message';
}

class ApiClient {
  ApiClient({
    String? baseUrl,
    AppRuntimeConfig? runtimeConfig,
    Duration? requestTimeout,
    /// Chatbot calls the backend proxy, which may wait on a remote bot (see
    /// `CHATBOT_TIMEOUT_MS`). Keep this comfortably above typical proxy latency.
    Duration? chatbotRequestTimeout,
    http.Client? httpClient,
  }) : _baseUrl =
           (baseUrl != null && baseUrl.isNotEmpty)
               ? baseUrl
               : (runtimeConfig ?? AppRuntimeConfig.fromEnvironment)
                   .resolveApiBaseUrl(Uri.base),
       _requestTimeout = requestTimeout ?? const Duration(seconds: 15),
       _chatbotRequestTimeout =
           chatbotRequestTimeout ?? const Duration(seconds: 90),
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final Duration _requestTimeout;
  final Duration _chatbotRequestTimeout;
  final http.Client _httpClient;

  Map<String, String> _authHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, String> _jsonHeaders(String token) {
    return {..._authHeaders(token), 'Content-Type': 'application/json'};
  }

  /// Extracts a human-friendly message from a backend JSON error body.
  ///
  /// The backend convention is `{ "message": "..." }`, but we fall back to
  /// the raw body (and then to a generic label) so unexpected error shapes
  /// still surface something useful to callers.
  String _extractErrorMessage(http.Response response, String fallback) {
    final body = response.body;
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final message = decoded['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message;
          }
        }
      } catch (_) {
        // Non-JSON body; fall through to raw body.
      }
      final trimmed = body.trim();
      if (trimmed.isNotEmpty) {
        return _humanizeNonJsonErrorBody(trimmed);
      }
    }
    return fallback;
  }

  /// Proxies/CDNs often return HTML bodies (e.g. Cloudflare 502). Never show
  /// that verbatim in the chat UI.
  String _humanizeNonJsonErrorBody(String body) {
    final lower = body.toLowerCase();
    if (body.trimLeft().startsWith('<!') ||
        lower.startsWith('<html') ||
        lower.contains('cloudflare') && lower.contains('cf-')) {
      return 'Gateway returned an HTML error page (often a proxy/CDN issue). '
          'Confirm the API is up and can reach the chatbot upstream.';
    }
    if (body.length > 280) {
      return '${body.substring(0, 280)}…';
    }
    return body;
  }

  /// Wraps an HTTP call with a timeout and converts network-level failures
  /// into [ApiClientException] so call sites only need to handle one type.
  Future<http.Response> _send(
    Future<http.Response> Function() request,
    String fallback, {
    Duration? timeout,
  }) async {
    try {
      return await request().timeout(timeout ?? _requestTimeout);
    } on ApiClientException {
      rethrow;
    } catch (error) {
      throw ApiClientException('$fallback: $error');
    }
  }
}
