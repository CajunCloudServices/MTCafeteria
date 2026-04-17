import 'package:flutter/material.dart';

import '../models/chatbot.dart';

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
  });

  final String role;
  final String text;
}

class GlobalChatWidget extends StatefulWidget {
  const GlobalChatWidget({
    super.key,
    required this.loadHealth,
    required this.sendMessage,
  });

  final Future<ChatbotHealth> Function() loadHealth;
  final Future<ChatbotReply> Function(String message, String? sessionId)
  sendMessage;

  @override
  State<GlobalChatWidget> createState() => _GlobalChatWidgetState();
}

class _GlobalChatWidgetState extends State<GlobalChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = const [
    ChatMessage(
      role: 'assistant',
      text:
          'MTC Dining Assistant is ready. Ask about setup, during-shift, cleanup, guides, or training content.',
    ),
  ].toList();

  bool _isOpen = false;
  bool _isSending = false;
  ChatbotHealth? _health;
  String? _sessionId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureHealthLoaded() async {
    if (_health != null) return;
    final health = await widget.loadHealth();
    if (!mounted) return;
    setState(() {
      _health = health;
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(role: 'user', text: text));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await widget.sendMessage(text, _sessionId);
      if (!mounted) return;
      setState(() {
        _sessionId = reply.sessionId;
        _messages.add(ChatMessage(role: 'assistant', text: reply.reply));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            text: 'Chatbot unavailable: $error',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isOpen ? _buildPanel(context) : _buildFab(context),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      key: const ValueKey('global-chat-open'),
      onPressed: () async {
        setState(() {
          _isOpen = true;
        });
        await _ensureHealthLoaded();
      },
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('MTC Assistant'),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final theme = Theme.of(context);
    final health = _health;
    final statusText = health == null
        ? 'Connecting'
        : health.ok
        ? 'Connected'
        : health.message ?? health.status;

    return Material(
      key: const ValueKey('global-chat-panel'),
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 360,
        height: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBCD0E7)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F8FE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MTC Dining Assistant',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B6786),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('global-chat-close'),
                    onPressed: () {
                      setState(() {
                        _isOpen = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.role == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFDCEBFC)
                            : const Color(0xFFF6F8FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(message.text),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('global-chat-input'),
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: const InputDecoration(
                        labelText: 'Ask a question',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    key: const ValueKey('global-chat-send'),
                    onPressed: _isSending ? null : _handleSend,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
