/// Central runtime configuration for web, local development, and pilot mode.
///
/// Everything here is resolved from `--dart-define` values so the same build
/// can be deployed with different behavior without editing source code.
class AppRuntimeConfig {
  const AppRuntimeConfig({
    required this.apiBaseUrl,
    required this.appMode,
    required this.appProfile,
    required this.featureManagerPortal,
    required this.featurePoints,
    required this.featureDailyShiftReports,
    required this.featureTrainings,
    required this.featureReferences,
  });

  final String apiBaseUrl;
  final String appMode;
  final String appProfile;
  final String featureManagerPortal;
  final String featurePoints;
  final String featureDailyShiftReports;
  final String featureTrainings;
  final String featureReferences;

  static const AppRuntimeConfig fromEnvironment = AppRuntimeConfig(
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: ''),
    appMode: String.fromEnvironment('APP_MODE', defaultValue: 'dev'),
    appProfile: String.fromEnvironment('APP_PROFILE', defaultValue: 'full'),
    featureManagerPortal: String.fromEnvironment(
      'FEATURE_MANAGER_PORTAL',
      defaultValue: 'auto',
    ),
    featurePoints: String.fromEnvironment(
      'FEATURE_POINTS',
      defaultValue: 'auto',
    ),
    featureDailyShiftReports: String.fromEnvironment(
      'FEATURE_DAILY_SHIFT_REPORTS',
      defaultValue: 'auto',
    ),
    featureTrainings: String.fromEnvironment(
      'FEATURE_TRAININGS',
      defaultValue: 'auto',
    ),
    featureReferences: String.fromEnvironment(
      'FEATURE_REFERENCES',
      defaultValue: 'auto',
    ),
  );

  bool get isPilotProfile => appProfile.trim().toLowerCase() == 'pilot';

  /// Chooses a backend base URL that works across local web, deployed web, and
  /// file-based launch paths used by some simulator/browser setups.
  String resolveApiBaseUrl(Uri browserUri) {
    if (apiBaseUrl.isNotEmpty) return apiBaseUrl;

    final scheme = browserUri.scheme.toLowerCase();
    final isHttpScheme = scheme == 'http' || scheme == 'https';

    // iOS (and some desktop launch paths) can run from file:// URIs.
    // Uri.origin is invalid for non-http(s) schemes, so short-circuit first.
    if (!isHttpScheme) {
      return 'http://localhost:3201';
    }

    final isLocalHost =
        browserUri.host == 'localhost' || browserUri.host == '127.0.0.1';

    if (isLocalHost) {
      return 'http://localhost:3201';
    }

    return browserUri.origin;
  }
}
