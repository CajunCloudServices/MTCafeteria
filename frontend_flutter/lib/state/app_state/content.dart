part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateContent on AppState {
  Future<void> refreshLandingItems() async {
    if (!isAuthenticated) return;
    final data = await _apiClient.getLandingItems(_token!);
    landingItems = data;
    _stateChanged();
  }

  /// Loads the legacy backend training feed used by older dashboard/panel
  /// flows.
  ///
  /// The active detailed 2-minute training experience now reads the manual
  /// local corpus from `training_text_data.dart` via `TrainingDetailPage`.
  Future<void> refreshTrainingsIfAllowed() async {
    if (!isAuthenticated ||
        !_features.trainingsEnabled ||
        !(user?.canViewTrainings ?? false)) {
      trainings = const [];
      todaysTraining = null;
      trainingDate = null;
      _stateChanged();
      return;
    }

    final data = await _apiClient.getTrainings(_token!);
    trainings = data.trainings;
    todaysTraining = data.todaysTraining;
    trainingDate = data.today;
    _stateChanged();
  }

  Future<void> createLandingItem(Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.createLandingItem(_token!, payload);
    await refreshLandingItems();
  }

  Future<void> updateLandingItem(int id, Map<String, dynamic> payload) async {
    if (!isAuthenticated) return;
    await _apiClient.updateLandingItem(_token!, id, payload);
    await refreshLandingItems();
  }

  Future<void> deleteLandingItem(int id) async {
    if (!isAuthenticated) return;
    await _apiClient.deleteLandingItem(_token!, id);
    await refreshLandingItems();
  }

}
