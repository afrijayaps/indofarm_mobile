import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/auth/auth_controller.dart';
import 'package:indofarm_mobile/src/application/auth/auth_state.dart';
import 'package:indofarm_mobile/src/application/providers.dart';
import 'package:indofarm_mobile/src/domain/models/app_user.dart';
import 'package:indofarm_mobile/src/domain/models/auth_session.dart';
import 'package:indofarm_mobile/src/domain/models/farm.dart';
import 'package:indofarm_mobile/src/domain/models/recording.dart';
import 'package:indofarm_mobile/src/domain/repositories/farm_repository.dart';
import 'package:indofarm_mobile/src/presentation/common/home_screen.dart';

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController(AuthState state) : super(state);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}
}

class _FakeFarmRepository implements FarmRepository {
  @override
  Future<List<Farm>> getFarms() async => const [Farm(id: 1, name: 'Farm A')];

  @override
  Future<Map<String, dynamic>> getFarmSummary(int farmId, {int? days}) async {
    final d = days ?? 7;
    if (d == 7) {
      return {
        'latest_recording_date': '2026-03-09',
        'period': {'from': '2026-03-03', 'to': '2026-03-09'},
        'metrics': {
          'total_egg_count': 700,
          'total_egg_kg': 70,
          'total_feed_kg': 140,
          'recording_count': 7,
          'avg_feed_per_day_kg': 20,
          'population': 1000,
          'hd_percent': 10,
        },
      };
    }

    return {
      'latest_recording_date': '2026-03-09',
      'period': {'from': '2026-02-10', 'to': '2026-03-09'},
      'metrics': {
        'total_egg_count': 700 * (d / 7),
        'total_egg_kg': 70 * (d / 7),
        'total_feed_kg': 140 * (d / 7),
        'recording_count': d,
        'avg_feed_per_day_kg': 20,
        'population': 1000,
        'hd_percent': 10,
      },
    };
  }

  @override
  Future<List<RecordingDraft>> getDraftsByFarm(int farmId) async => const [];
}

void main() {
  testWidgets('home screen shows inventory tab and placeholder', (
    tester,
  ) async {
    final fakeAuth = _FakeAuthController(
      AuthState.authenticated(
        AuthSession(
          token: 'token',
          tokenType: 'Bearer',
          user: const AppUser(
            id: 1,
            name: 'Tester',
            email: 'tester@example.com',
            role: 'operator',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => fakeAuth),
          farmRepositoryProvider.overrideWithValue(_FakeFarmRepository()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    expect(
      find.text('Inventory is under construction'),
      findsAtLeastNWidgets(1),
    );
  });
}
