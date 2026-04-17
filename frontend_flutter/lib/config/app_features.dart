import 'runtime_config.dart';

/// Resolves which top-level product areas should be visible for the current
/// runtime configuration. Features default on and can be disabled explicitly
/// via `--dart-define` toggles at build time.
class AppFeatures {
  const AppFeatures({
    required this.referencesEnabled,
    required this.trainingsEnabled,
    required this.pointsEnabled,
    required this.dailyShiftReportsEnabled,
    required this.managerPortalEnabled,
    required this.chatbotEnabled,
  });

  final bool referencesEnabled;
  final bool trainingsEnabled;
  final bool pointsEnabled;
  final bool dailyShiftReportsEnabled;
  final bool managerPortalEnabled;
  final bool chatbotEnabled;

  static AppFeatures fromRuntimeConfig(AppRuntimeConfig config) {
    bool resolveToggle(String value) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'off' || normalized == 'false') return false;
      return true;
    }

    return AppFeatures(
      referencesEnabled: resolveToggle(config.featureReferences),
      trainingsEnabled: resolveToggle(config.featureTrainings),
      pointsEnabled: resolveToggle(config.featurePoints),
      dailyShiftReportsEnabled: resolveToggle(config.featureDailyShiftReports),
      managerPortalEnabled: resolveToggle(config.featureManagerPortal),
      chatbotEnabled: resolveToggle(config.featureChatbot),
    );
  }
}
