import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/config/app_features.dart';
import 'package:frontend_flutter/config/runtime_config.dart';

void main() {
  group('AppRuntimeConfig.resolveApiBaseUrl', () {
    const baseConfig = AppRuntimeConfig(
      apiBaseUrl: '',
      appMode: 'test',
      featureManagerPortal: 'auto',
      featureChatbot: 'auto',
      featurePoints: 'auto',
      featureDailyShiftReports: 'auto',
      featureTrainings: 'auto',
      featureReferences: 'auto',
    );

    test('uses normalized API_BASE_URL override when provided', () {
      const config = AppRuntimeConfig(
        apiBaseUrl: ' https://cafeteria.example.com/ ',
        appMode: 'prod',
        featureManagerPortal: 'auto',
        featureChatbot: 'auto',
        featurePoints: 'auto',
        featureDailyShiftReports: 'auto',
        featureTrainings: 'auto',
        featureReferences: 'auto',
      );

      expect(
        config.resolveApiBaseUrl(Uri.parse('https://ignored.example.com/app')),
        'https://cafeteria.example.com',
      );
    });

    test('uses localhost fallback for localhost browser sessions', () {
      expect(
        baseConfig.resolveApiBaseUrl(Uri.parse('http://localhost:3006/')),
        'http://localhost:3201',
      );
      expect(
        baseConfig.resolveApiBaseUrl(Uri.parse('https://127.0.0.1:3006/app')),
        'http://localhost:3201',
      );
    });

    test('uses localhost fallback for non-http launch schemes', () {
      expect(
        baseConfig.resolveApiBaseUrl(Uri.parse('file:///tmp/index.html')),
        'http://localhost:3201',
      );
    });

    test('uses current origin for deployed same-origin hosting', () {
      expect(
        baseConfig.resolveApiBaseUrl(
          Uri.parse('https://cafeteria.example.com/dashboard/line'),
        ),
        'https://cafeteria.example.com',
      );
    });
  });

  group('AppFeatures.fromRuntimeConfig', () {
    test('defaults auto values to enabled', () {
      const config = AppRuntimeConfig(
        apiBaseUrl: '',
        appMode: 'prod',
        featureManagerPortal: 'auto',
        featureChatbot: 'auto',
        featurePoints: 'auto',
        featureDailyShiftReports: 'auto',
        featureTrainings: 'auto',
        featureReferences: 'auto',
      );

      final features = AppFeatures.fromRuntimeConfig(config);

      expect(features.managerPortalEnabled, isTrue);
      expect(features.chatbotEnabled, isTrue);
      expect(features.pointsEnabled, isTrue);
      expect(features.dailyShiftReportsEnabled, isTrue);
      expect(features.trainingsEnabled, isTrue);
      expect(features.referencesEnabled, isTrue);
    });

    test('treats explicit false/off values as disabled', () {
      const config = AppRuntimeConfig(
        apiBaseUrl: '',
        appMode: 'prod',
        featureManagerPortal: 'false',
        featureChatbot: 'off',
        featurePoints: 'off',
        featureDailyShiftReports: 'FALSE',
        featureTrainings: ' Off ',
        featureReferences: 'false',
      );

      final features = AppFeatures.fromRuntimeConfig(config);

      expect(features.managerPortalEnabled, isFalse);
      expect(features.chatbotEnabled, isFalse);
      expect(features.pointsEnabled, isFalse);
      expect(features.dailyShiftReportsEnabled, isFalse);
      expect(features.trainingsEnabled, isFalse);
      expect(features.referencesEnabled, isFalse);
    });
  });
}
