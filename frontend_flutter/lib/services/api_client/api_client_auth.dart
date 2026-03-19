part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientAuth on ApiClient {
  /// Creates a session token plus the minimal user payload needed by the app.
  Future<({String token, UserSession user})> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;

    return (
      token: data['token'] as String,
      user: UserSession(
        id: userJson['id'] as int,
        email: userJson['email'] as String,
        role: userJson['role'] as String,
        points: userJson['points'] as int? ?? 0,
      ),
    );
  }
}
