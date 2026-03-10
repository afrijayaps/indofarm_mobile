import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/providers.dart';
import 'package:indofarm_mobile/src/domain/models/farm.dart';
import 'package:indofarm_mobile/src/domain/models/recording.dart';
import 'package:indofarm_mobile/src/domain/models/sync_job.dart';
import 'package:indofarm_mobile/src/domain/repositories/farm_repository.dart';
import 'package:indofarm_mobile/src/domain/repositories/recording_repository.dart';
import 'package:indofarm_mobile/src/domain/repositories/sync_repository.dart';
import 'package:indofarm_mobile/src/presentation/recordings/recording_form_screen.dart';

class _FakeFarmRepository implements FarmRepository {
  @override
  Future<List<Farm>> getFarms() async => const [Farm(id: 1, name: 'Farm A')];

  @override
  Future<Map<String, dynamic>> getFarmSummary(int farmId, {int? days}) async =>
      <String, dynamic>{};

  @override
  Future<List<RecordingDraft>> getDraftsByFarm(int farmId) async => const [];
}

class _FakeRecordingRepository implements RecordingRepository {
  final List<RecordingPayload> submitted = <RecordingPayload>[];

  @override
  Future<RecordingFormOptions> getFormOptions(int farmId) async =>
      const RecordingFormOptions(
        farm: RecordingFormFarm(
          id: 1,
          name: 'Farm A',
          jenisHewan: 'ayam',
          profileLabel: 'Layer',
          livestockLabel: 'Ayam Layer',
        ),
        cages: [RecordingFormCage(id: 11, name: 'Kandang 1', code: 'A1')],
        modeButirDefault: 'manual',
        estimasiBeratButirGrDefault: 60,
        tanggalToday: '2026-03-09',
        ayamKeluarTypes: {'mati': 'Mati'},
        telurTypes: {'utuh': 'Utuh'},
        jamLampuOptions: [12, 14, 16],
        qtyUnits: {'gr': 'gr'},
        treatmentTypes: {'obat': 'Obat'},
        feedItems: [RecordingFeedInventoryItem(id: 9, name: 'Feed A')],
        defaultFeedItemByCage: {11: 9},
      );

  @override
  Future<void> submitRecording(RecordingPayload payload) async {
    submitted.add(payload);
  }

  @override
  Future<RecordingDraft> saveDraft(RecordingPayload payload) async {
    return RecordingDraft(
      id: 1,
      payload: payload,
      status: DraftStatus.pending,
      createdAt: DateTime(2026, 3, 9),
    );
  }

  @override
  Future<List<RecordingDraft>> getDrafts() async => const [];

  @override
  Future<void> updateDraftStatus(int draftId, DraftStatus status) async {}
}

class _FakeSyncRepository implements SyncRepository {
  @override
  Future<List<SyncJob>> getJobs() async => const [];

  @override
  Future<void> upsertPendingJob(int draftId) async {}

  @override
  Future<void> updateJobStatus(
    int draftId,
    SyncStatus status, {
    String? errorMessage,
  }) async {}
}

void main() {
  testWidgets('recording form validates pakan step before moving forward', (
    tester,
  ) async {
    final fakeRecording = _FakeRecordingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          farmRepositoryProvider.overrideWithValue(_FakeFarmRepository()),
          recordingRepositoryProvider.overrideWithValue(fakeRecording),
          syncRepositoryProvider.overrideWithValue(_FakeSyncRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: RecordingFormScreen())),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3 dari 4'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Pakan pagi wajib diisi'), findsOneWidget);
    expect(fakeRecording.submitted, isEmpty);
  });

  testWidgets('recording form supports next and back navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          farmRepositoryProvider.overrideWithValue(_FakeFarmRepository()),
          recordingRepositoryProvider.overrideWithValue(
            _FakeRecordingRepository(),
          ),
          syncRepositoryProvider.overrideWithValue(_FakeSyncRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: RecordingFormScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Step 1 dari 4'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 dari 4'), findsOneWidget);

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 dari 4'), findsOneWidget);
  });

  testWidgets('recording form keeps step titles and delete action works', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          farmRepositoryProvider.overrideWithValue(_FakeFarmRepository()),
          recordingRepositoryProvider.overrideWithValue(
            _FakeRecordingRepository(),
          ),
          syncRepositoryProvider.overrideWithValue(_FakeSyncRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: RecordingFormScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Info Dasar & Populasi'), findsOneWidget);
    expect(find.text('Produksi Telur'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 dari 4'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);

    final deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Hapus').first,
    );
    deleteButton.onPressed?.call();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('Minimal ada 1 baris telur'), findsOneWidget);
  });
}
