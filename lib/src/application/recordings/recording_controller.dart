import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../domain/models/recording.dart';
import '../../domain/models/sync_job.dart';
import '../providers.dart';

class RecordingSubmitState {
  const RecordingSubmitState({
    this.isSubmitting = false,
    this.message,
    this.error,
  });

  final bool isSubmitting;
  final String? message;
  final String? error;
}

class RecordingController extends StateNotifier<RecordingSubmitState> {
  RecordingController(this._ref) : super(const RecordingSubmitState());

  final Ref _ref;

  Future<void> submit(RecordingPayload payload) async {
    state = const RecordingSubmitState(isSubmitting: true);
    final recordingRepo = _ref.read(recordingRepositoryProvider);
    final syncRepo = _ref.read(syncRepositoryProvider);
    try {
      await recordingRepo.submitRecording(payload);
      state = const RecordingSubmitState(message: 'Recording berhasil dikirim');
    } on ApiException catch (_) {
      final draft = await recordingRepo.saveDraft(payload);
      await syncRepo.upsertPendingJob(draft.id);
      state = const RecordingSubmitState(
        message: 'Jaringan bermasalah. Draft disimpan untuk disinkronkan.',
      );
    } catch (_) {
      state = const RecordingSubmitState(
        error: 'Gagal submit recording. Coba lagi.',
      );
    }
  }

  Future<void> retryDraft(RecordingDraft draft) async {
    final recordingRepo = _ref.read(recordingRepositoryProvider);
    final syncRepo = _ref.read(syncRepositoryProvider);
    try {
      await recordingRepo.submitRecording(draft.payload);
      await recordingRepo.updateDraftStatus(draft.id, DraftStatus.synced);
      await syncRepo.updateJobStatus(draft.id, SyncStatus.synced);
      state = const RecordingSubmitState(message: 'Draft berhasil disinkronkan');
    } on ApiException catch (e) {
      await recordingRepo.updateDraftStatus(draft.id, DraftStatus.failed);
      await syncRepo.updateJobStatus(
        draft.id,
        SyncStatus.failed,
        errorMessage: e.message,
      );
      state = RecordingSubmitState(error: e.message);
    }
  }
}

final recordingControllerProvider =
    StateNotifierProvider<RecordingController, RecordingSubmitState>(
      (ref) => RecordingController(ref),
    );

final recordingDraftsProvider = FutureProvider<List<RecordingDraft>>((ref) async {
  return ref.watch(recordingRepositoryProvider).getDrafts();
});
