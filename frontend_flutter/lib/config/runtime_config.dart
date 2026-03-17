import 'package:flutter/foundation.dart';

/// Central runtime configuration for web, local development, and pilot mode.
///
/// Everything here is resolved from `--dart-define` values so the same build
/// can be deployed with different behavior without editing source code.
class AppRuntimeConfig {
  const AppRuntimeConfig({
    required this.apiBaseUrl,
    required this.devBypassAuth,
    required this.appMode,
    required this.appProfile,
    required this.devBypassEmail,
    required this.devBypassPassword,
    required this.pilotAutoLoginEmail,
    required this.pilotAutoLoginPassword,
    required this.featureManagerPortal,
    required this.featurePoints,
    required this.featureDailyShiftReports,
    required this.featureTrainings,
    required this.featureReferences,
  });

  final String apiBaseUrl;
  final bool devBypassAuth;
  final String appMode;
  final String appProfile;
  final String devBypassEmail;
  final String devBypassPassword;
  final String pilotAutoLoginEmail;
  final String pilotAutoLoginPassword;
  final String featureManagerPortal;
  final String featurePoints;
  final String featureDailyShiftReports;
  final String featureTrainings;
  final String featureReferences;

  static const AppRuntimeConfig fromEnvironment = AppRuntimeConfig(
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: ''),
    devBypassAuth: bool.fromEnvironment('DEV_BYPASS_AUTH', defaultValue: false),
    appMode: String.fromEnvironment('APP_MODE', defaultValue: 'dev'),
    appProfile: String.fromEnvironment('APP_PROFILE', defaultValue: 'full'),
    devBypassEmail: String.fromEnvironment(
      'DEV_BYPASS_EMAIL',
      defaultValue: 'manager@mtc.local',
    ),
    devBypassPassword: String.fromEnvironment(
      'DEV_BYPASS_PASSWORD',
      defaultValue: 'password123',
    ),
    pilotAutoLoginEmail: String.fromEnvironment(
      'PILOT_AUTO_LOGIN_EMAIL',
      defaultValue: 'supervisor@mtc.local',
    ),
    pilotAutoLoginPassword: String.fromEnvironment(
      'PILOT_AUTO_LOGIN_PASSWORD',
      defaultValue: 'password123',
    ),
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

  /// Dev bypass is intentionally disabled in release builds even if the flag is
  /// present, so a production deployment cannot silently skip auth.
  bool get devBypassEnabled {
    if (kReleaseMode) return false;
    if (!devBypassAuth) return false;
    return appMode.toLowerCase() != 'prod';
  }

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
