part of 'package:frontend_flutter/state/app_state.dart';

extension AppStateReports on AppState {
  Future<void> loadCurrentLineShiftReport({String? meal}) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    final selectedMeal = meal ?? supervisorBoard?.selectedMeal ?? 'Breakfast';
    currentLineShiftReportError = null;

    try {
      currentLineShiftReport = await _apiClient.getCurrentDailyShiftReport(
        _token!,
        meal: selectedMeal,
      );
    } catch (e) {
      currentLineShiftReport = null;
      currentLineShiftReportError = 'Could not load daily shift report.';
      debugPrint('Daily shift report load failed: $e');
    }
    _stateChanged();
  }

  Future<void> saveCurrentLineShiftReportDraft({
    required String meal,
    required Map<String, String> payload,
  }) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    currentLineShiftReport = await _apiClient.saveDailyShiftReportDraft(
      _token!,
      meal: meal,
      payload: payload,
    );
    currentLineShiftReportError = null;
    _stateChanged();
  }

  Future<void> submitCurrentLineShiftReport({
    required String meal,
    required Map<String, String> payload,
  }) async {
    if (!isAuthenticated || !canAccessSupervisorBoard) return;
    currentLineShiftReport = await _apiClient.submitDailyShiftReport(
      _token!,
      meal: meal,
      payload: payload,
    );
    currentLineShiftReportError = null;
    _stateChanged();
    if (_features.dailyShiftReportsEnabled && canViewDailyShiftReports) {
      await refreshDailyShiftReports();
    }
  }

  Future<void> refreshDailyShiftReports() async {
    if (!isAuthenticated ||
        !_features.dailyShiftReportsEnabled ||
        !canViewDailyShiftReports) {
      return;
    }
    dailyShiftReportsError = null;
    try {
      dailyShiftReports = await _apiClient.getDailyShiftReports(_token!);
    } catch (e) {
      dailyShiftReports = const [];
      dailyShiftReportsError = 'Could not load daily shift reports.';
      debugPrint('Daily shift reports list failed: $e');
    }
    _stateChanged();
  }
}
