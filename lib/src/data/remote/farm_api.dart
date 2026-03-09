import '../../core/network/api_client.dart';
import '../../domain/models/farm.dart';

class FarmApi {
  const FarmApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Farm>> getFarms() async {
    final response = await _apiClient.get('/farms');
    final list = (response['data'] as List?) ?? <dynamic>[];
    return list
        .map((e) => Farm.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getFarmSummary(int farmId) async {
    final response = await _apiClient.get('/farms/$farmId/summary');
    final summary = response['data'] as Map<String, dynamic>? ?? {};
    return summary;
  }
}
