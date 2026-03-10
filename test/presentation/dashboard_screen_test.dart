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
import 'package:indofarm_mobile/src/presentation/dashboard/dashboard_screen.dart';

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
  Future<List<Farm>> getFarms() async => const [
    Farm(id: 10, name: 'Farm Utama'),
  ];

  @override
  Future<Map<String, dynamic>> getFarmSummary(int farmId, {int? days}) async {
    final d = days ?? 7;

    if (d == 7) {
      return {
        'latest_recording_date': '2026-03-09',
        'period': {'from': '2026-03-03', 'to': '2026-03-09'},
        'metrics': {
          'total_egg_count': 7000,
          'total_egg_kg': 420,
          'total_feed_kg': 840,
          'recording_count': 7,
          'avg_feed_per_day_kg': 120,
          'population': 10000,
          'hd_percent': 10,
        },
      };
    }

    if (d == 14) {
      return {
        'latest_recording_date': '2026-03-09',
        'period': {'from': '2026-02-24', 'to': '2026-03-09'},
        'metrics': {
          'total_egg_count': 13000,
          'total_egg_kg': 760,
          'total_feed_kg': 1650,
          'recording_count': 14,
          'avg_feed_per_day_kg': 117.9,
          'population': 10000,
          'hd_percent': 9.29,
        },
      };
    }

    if (d == 21) {
      return {
        'latest_recording_date': '2026-03-09',
        'period': {'from': '2026-02-17', 'to': '2026-03-09'},
        'metrics': {
          'total_egg_count': 18900,
          'total_egg_kg': 1090,
          'total_feed_kg': 2470,
          'recording_count': 21,
          'avg_feed_per_day_kg': 117.6,
          'population': 10000,
          'hd_percent': 9,
        },
      };
    }

    return {
      'latest_recording_date': '2026-03-09',
      'period': {'from': '2026-02-10', 'to': '2026-03-09'},
      'metrics': {
        'total_egg_count': 24500,
        'total_egg_kg': 1410,
        'total_feed_kg': 3300,
        'recording_count': 28,
        'avg_feed_per_day_kg': 117.8,
        'population': 10000,
        'hd_percent': 8.75,
      },
    };
  }

  @override
  Future<List<RecordingDraft>> getDraftsByFarm(int farmId) async => const [];
}

void main() {
  testWidgets('dashboard shows real metrics and weekly graph', (tester) async {
    final fakeAuth = _FakeAuthController(
      AuthState.authenticated(
        AuthSession(
          token: 'token',
          tokenType: 'Bearer',
          user: const AppUser(
            id: 1,
            name: 'Owner',
            email: 'owner@example.com',
            role: 'owner',
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
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Farm Snapshot'), findsOneWidget);
    expect(find.text('Total Egg (Butir)'), findsOneWidget);
    expect(find.text('Total Egg (Kg)'), findsOneWidget);
    expect(find.text('Total Feed (Kg)'), findsOneWidget);
    expect(find.text('Recording Count'), findsOneWidget);

    expect(find.text('7000'), findsOneWidget);
    expect(find.text('420 kg'), findsOneWidget);

    expect(find.text('Grafik Mingguan'), findsOneWidget);
    expect(find.text('HD (%) dan produksi telur (kg)'), findsOneWidget);
    expect(find.text('W-3'), findsOneWidget);
    expect(find.text('W-2'), findsOneWidget);
    expect(find.text('W-1'), findsOneWidget);
    expect(find.text('W0'), findsOneWidget);
  });
}
