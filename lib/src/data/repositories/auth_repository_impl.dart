import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApi authApi,
    required SessionStorage sessionStorage,
  })  : _authApi = authApi,
        _sessionStorage = sessionStorage;

  final AuthApi _authApi;
  final SessionStorage _sessionStorage;

  AuthSession? _cachedSession;

  @override
  Future<AuthSession?> readSession() async {
    _cachedSession = await _sessionStorage.read();
    return _cachedSession;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _authApi.login(email: email, password: password);
    _cachedSession = session;
    await _sessionStorage.write(session);
    return session;
  }

  @override
  Future<AuthSession> me() async {
    final current = _cachedSession ?? await _sessionStorage.read();
    if (current == null) {
      throw const ApiException('Session is missing');
    }
    final userOnly = await _authApi.me();
    final merged = AuthSession(
      token: current.token,
      tokenType: current.tokenType,
      user: userOnly.user,
    );
    _cachedSession = merged;
    await _sessionStorage.write(merged);
    return merged;
  }

  @override
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } finally {
      _cachedSession = null;
      await _sessionStorage.clear();
    }
  }
}
