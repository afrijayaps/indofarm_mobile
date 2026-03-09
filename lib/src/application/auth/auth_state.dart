import '../../domain/models/auth_session.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.error,
    this.verificationUrl,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? error;
  final String? verificationUrl;

  const AuthState.initializing() : this(status: AuthStatus.initializing);
  const AuthState.authenticated(AuthSession session)
      : this(status: AuthStatus.authenticated, session: session);
  const AuthState.unauthenticated({String? error, String? verificationUrl})
      : this(
          status: AuthStatus.unauthenticated,
          error: error,
          verificationUrl: verificationUrl,
        );
}
