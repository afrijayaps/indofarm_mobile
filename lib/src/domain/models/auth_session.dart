import 'app_user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userMap = rawUser is Map<String, dynamic>
        ? rawUser
        : {
            'id': json['id'],
            'name': json['name'],
            'email': json['email'],
            'role': json['role'],
          };

    return AuthSession(
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      user: AppUser.fromJson(userMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}
