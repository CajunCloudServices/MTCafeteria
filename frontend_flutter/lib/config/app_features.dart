import 'runtime_config.dart';

/// Resolves which top-level product areas should be visible for the current
/// runtime profile.
class AppFeatures {
  const AppFeatures({
    required this.referencesEnabled,
    required this.trainingsEnabled,
    required this.pointsEnabled,
    required this.dailyShiftReportsEnabled,
    required this.managerPortalEnabled,
  });

  final bool referencesEnabled;
  final bool trainingsEnabled;
  final bool pointsEnabled;
  final bool dailyShiftReportsEnabled;
  final bool managerPortalEnabled;

  /// Converts string-based environment toggles into concrete feature flags.
  ///
  /// In the full profile, features default on unless explicitly disabled.
  /// In pilot mode, the defaults are stricter so unfinished or sensitive
  /// features stay hidden even if no explicit override is provided.
  static AppFeatures fromRuntimeConfig(AppRuntimeConfig config) {
    final profile = config.appProfile.trim().toLowerCase();
    final isPilot = profile == 'pilot';

    bool resolveToggle(String value, {required bool pilotDefault}) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'on' || normalized == 'true') return true;
      if (normalized == 'off' || normalized == 'false') return false;
      return isPilot ? pilotDefault : true;
    }

    return AppFeatures(
      referencesEnabled: resolveToggle(
        config.featureReferences,
        pilotDefault: true,
      ),
      trainingsEnabled: resolveToggle(
        config.featureTrainings,
        pilotDefault: true,
      ),
      pointsEnabled: resolveToggle(config.featurePoints, pilotDefault: false),
      dailyShiftReportsEnabled: resolveToggle(
        config.featureDailyShiftReports,
        pilotDefault: false,
      ),
      managerPortalEnabled: resolveToggle(
        config.featureManagerPortal,
        pilotDefault: false,
      ),
    );
  }
}
