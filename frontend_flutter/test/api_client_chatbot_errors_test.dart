import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/services/api_client.dart';
import 'package:http/http.dart' as http;

class _Html502Client extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = utf8.encode(
      '<!DOCTYPE html><html><body class="cf-error">502</body></html>',
    );
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      502,
      headers: {'content-type': 'text/html'},
      contentLength: bytes.length,
    );
  }
}

void main() {
  test('chatbot health maps HTML 502 bodies to a short message', () async {
    final api = ApiClient(
      baseUrl: 'http://example.test',
      httpClient: _Html502Client(),
    );

    await expectLater(
      api.getChatbotHealth(),
      throwsA(
        predicate<dynamic>((Object? e) {
          expect(e, isA<ApiClientException>());
          final ex = e! as ApiClientException;
          expect(ex.statusCode, 502);
          expect(ex.message, isNot(contains('<!DOCTYPE')));
          expect(ex.message, contains('HTML'));
          return true;
        }),
      ),
    );
  });
}
