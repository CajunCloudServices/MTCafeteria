class ChatbotHealth {
  const ChatbotHealth({
    required this.ok,
    required this.configured,
    required this.status,
    this.message,
  });

  final bool ok;
  final bool configured;
  final String status;
  final String? message;

  factory ChatbotHealth.fromJson(Map<String, dynamic> json) {
    return ChatbotHealth(
      ok: json['ok'] == true,
      configured: json['configured'] != false,
      status: '${json['status'] ?? 'unknown'}',
      message: json['message'] as String?,
    );
  }
}

class ChatbotReply {
  const ChatbotReply({
    required this.reply,
    required this.sessionId,
  });

  final String reply;
  final String sessionId;

  factory ChatbotReply.fromJson(Map<String, dynamic> json) {
    return ChatbotReply(
      reply: '${json['reply'] ?? ''}',
      sessionId: '${json['sessionId'] ?? ''}',
    );
  }
}
