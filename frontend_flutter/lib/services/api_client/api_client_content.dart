part of 'package:frontend_flutter/services/api_client.dart';

extension ApiClientContent on ApiClient {
  Future<List<LandingItem>> getLandingItems(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch landing items');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => LandingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LandingItem> createLandingItem(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/content/landing-items'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<LandingItem> updateLandingItem(
    String token,
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _jsonHeaders(token),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update landing item');
    }
    return LandingItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteLandingItem(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/content/landing-items/$id'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete landing item');
    }
  }

  Future<({String today, List<Training> trainings, Training? todaysTraining})>
  getTrainings(String token) async {
    // Legacy prototype feed. The active detailed training viewer reads the
    // local manual corpus in `training_text_data.dart` instead of this API.
    final response = await http.get(
      Uri.parse('$_baseUrl/api/trainings'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trainings');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final trainings = (data['trainings'] as List<dynamic>)
        .map((e) => Training.fromJson(e as Map<String, dynamic>))
        .toList();

    // The backend returns both the full list and the currently highlighted
    // training so the UI can render either a full browser or a compact today
    // panel from the same payload.
    final todaysTrainingJson = data['todaysTraining'];
    return (
      today: data['today'] as String,
      trainings: trainings,
      todaysTraining: todaysTrainingJson == null
          ? null
          : Training.fromJson(todaysTrainingJson as Map<String, dynamic>),
    );
  }
}
