import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/models/chatbot.dart';
import 'package:frontend_flutter/widgets/global_chat_widget.dart';

void main() {
  testWidgets('global chat widget opens and sends a message', (tester) async {
    String? lastMessage;
    String? lastSessionId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              GlobalChatWidget(
                loadHealth: () async => const ChatbotHealth(
                  ok: true,
                  configured: true,
                  status: 'ok',
                ),
                sendMessage: (message, sessionId) async {
                  lastMessage = message;
                  lastSessionId = sessionId;
                  return const ChatbotReply(
                    reply: 'Here are the beverages setup steps.',
                    sessionId: 'session-123',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('global-chat-open')));
    await tester.pumpAndSettle();

    expect(find.text('MTC Dining Assistant'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('global-chat-input')),
      'What are the setup tasks for beverages?',
    );
    await tester.tap(find.byKey(const ValueKey('global-chat-send')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(lastMessage, 'What are the setup tasks for beverages?');
    expect(lastSessionId, isNull);
    expect(find.text('Here are the beverages setup steps.'), findsOneWidget);
  });
}
