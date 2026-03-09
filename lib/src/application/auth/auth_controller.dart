import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/auth_session.dart';
import '../providers.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState.initializing()) {
    bootstrap();
  }

  final Ref _ref;

  Future<void> bootstrap() async {
    final authRepo = _ref.read(authRepositoryProvider);
    final session = await authRepo.readSession();
    if (session == null || session.token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    _setToken(session);
    try {
      final refreshed = await authRepo.me();
      _setToken(refreshed);
      state = AuthState.authenticated(refreshed);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final authRepo = _ref.read(authRepositoryProvider);
    state = const AuthState.initializing();
    try {
      final session = await authRepo.login(email: email, password: password);
      _setToken(session);
      state = AuthState.authenticated(session);
    } on ApiException catch (e) {
      if (e.statusCode == 409 && e.code == 'PHONE_VERIFICATION_REQUIRED') {
        final redirect = e.meta?['redirect']?.toString();
        state = AuthState.unauthenticated(
          error: e.message,
          verificationUrl: redirect,
        );
      } else {
        state = AuthState.unauthenticated(error: e.message);
      }
    } catch (_) {
      state = const AuthState.unauthenticated(
        error: 'Login failed. Please retry.',
      );
    }
  }

  Future<void> logout() async {
    final authRepo = _ref.read(authRepositoryProvider);
    await authRepo.logout();
    _ref.read(tokenStoreProvider).token = null;
    state = const AuthState.unauthenticated();
  }

  void _setToken(AuthSession session) {
    _ref.read(tokenStoreProvider).token = session.token;
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);
