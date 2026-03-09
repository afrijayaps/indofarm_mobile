class AppConfig {
  const AppConfig({
    required this.baseUrl,
    this.timeoutSeconds = 20,
    this.deviceName = 'android-app',
  });

  final String baseUrl;
  final int timeoutSeconds;
  final String deviceName;
}

const appConfig = AppConfig(
  baseUrl: String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://indofarm.app/api/v1',
  ),
);
