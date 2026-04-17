part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientChatbot on ApiClient {
  Future<ChatbotHealth> getChatbotHealth() async {
    final response = await _send(
      () => http.get(Uri.parse('$_baseUrl/api/chatbot/health')),
      'Failed to load chatbot health',
    );

    if (response.statusCode != 200 && response.statusCode != 503) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to load chatbot health'),
        statusCode: response.statusCode,
      );
    }

    return ChatbotHealth.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ChatbotReply> sendChatbotMessage(
    String message, {
    String? sessionId,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$_baseUrl/api/chatbot/chat'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
        }),
      ),
      'Failed to send chatbot message',
    );

    if (response.statusCode != 200) {
      throw ApiClientException(
        _extractErrorMessage(response, 'Failed to send chatbot message'),
        statusCode: response.statusCode,
      );
    }

    return ChatbotReply.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
