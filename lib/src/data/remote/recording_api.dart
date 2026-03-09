import '../../core/network/api_client.dart';
import '../../domain/models/recording.dart';

class RecordingApi {
  const RecordingApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> submit(RecordingPayload payload) async {
    await _apiClient.post(
      '/farms/${payload.farmId}/recordings',
      body: payload.toJson(),
    );
  }
}
