import '../../core/network/api_exception.dart';
import '../../domain/models/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../local/recording_local_data_source.dart';
import '../remote/recording_api.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  RecordingRepositoryImpl({
    required RecordingApi recordingApi,
    required RecordingLocalDataSource localDataSource,
  })  : _recordingApi = recordingApi,
        _localDataSource = localDataSource;

  final RecordingApi _recordingApi;
  final RecordingLocalDataSource _localDataSource;

  @override
  Future<void> submitRecording(RecordingPayload payload) {
    return _recordingApi.submit(payload);
  }

  @override
  Future<RecordingDraft> saveDraft(RecordingPayload payload) {
    return _localDataSource.insertDraft(payload);
  }

  @override
  Future<List<RecordingDraft>> getDrafts() {
    return _localDataSource.getDrafts();
  }

  @override
  Future<void> updateDraftStatus(int draftId, DraftStatus status) async {
    if (!DraftStatus.values.contains(status)) {
      throw const ApiException('Invalid draft status');
    }
    await _localDataSource.updateDraftStatus(draftId, status);
  }
}
