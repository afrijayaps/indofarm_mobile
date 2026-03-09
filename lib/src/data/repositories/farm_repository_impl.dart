import '../../domain/models/farm.dart';
import '../../domain/models/recording.dart';
import '../../domain/repositories/farm_repository.dart';
import '../local/recording_local_data_source.dart';
import '../remote/farm_api.dart';

class FarmRepositoryImpl implements FarmRepository {
  FarmRepositoryImpl({
    required FarmApi farmApi,
    required RecordingLocalDataSource recordingLocalDataSource,
  })  : _farmApi = farmApi,
        _recordingLocalDataSource = recordingLocalDataSource;

  final FarmApi _farmApi;
  final RecordingLocalDataSource _recordingLocalDataSource;

  @override
  Future<List<Farm>> getFarms() => _farmApi.getFarms();

  @override
  Future<Map<String, dynamic>> getFarmSummary(int farmId) {
    return _farmApi.getFarmSummary(farmId);
  }

  @override
  Future<List<RecordingDraft>> getDraftsByFarm(int farmId) {
    return _recordingLocalDataSource.getDraftsByFarm(farmId);
  }
}
