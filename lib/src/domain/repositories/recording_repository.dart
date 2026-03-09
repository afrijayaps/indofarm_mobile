import '../models/recording.dart';

abstract class RecordingRepository {
  Future<void> submitRecording(RecordingPayload payload);
  Future<RecordingDraft> saveDraft(RecordingPayload payload);
  Future<List<RecordingDraft>> getDrafts();
  Future<void> updateDraftStatus(int draftId, DraftStatus status);
}
