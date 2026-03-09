import '../models/farm.dart';
import '../models/recording.dart';

abstract class FarmRepository {
  Future<List<Farm>> getFarms();
  Future<Map<String, dynamic>> getFarmSummary(int farmId);
  Future<List<RecordingDraft>> getDraftsByFarm(int farmId);
}
