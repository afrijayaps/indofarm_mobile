import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../domain/models/auth_session.dart';

class AuthApi {
  const AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': appConfig.deviceName,
      },
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final user = _extractUserMap(data);
    return AuthSession.fromJson({
      'token': data['token']?.toString() ?? data['access_token']?.toString() ?? '',
      'token_type': data['token_type']?.toString() ?? 'Bearer',
      'user': user,
    });
  }

  Future<AuthSession> me() async {
    final response = await _apiClient.get('/me');
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final user = _extractUserMap(data);
    return AuthSession.fromJson({
      'token': '',
      'token_type': 'Bearer',
      'user': user,
    });
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> payload) {
    final nested = payload['user'];
    if (nested is Map) {
      return nested.cast<String, dynamic>();
    }
    return payload;
  }
}
