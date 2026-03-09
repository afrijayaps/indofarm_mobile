import '../models/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> readSession();
  Future<AuthSession> login({
    required String email,
    required String password,
  });
  Future<AuthSession> me();
  Future<void> logout();
}
