import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/domain/models/auth_session.dart';

void main() {
  test('AuthSession fromJson maps token and role correctly', () {
    final session = AuthSession.fromJson({
      'token': 'abc',
      'token_type': 'Bearer',
      'user': {
        'id': 10,
        'name': 'Operator A',
        'email': 'operator@example.com',
        'role': 'operator',
      },
    });

    expect(session.token, 'abc');
    expect(session.user.role, 'operator');
    expect(session.user.canInputRecording, isTrue);
  });
}
