import '../models/sync_job.dart';

abstract class SyncRepository {
  Future<void> upsertPendingJob(int draftId);
  Future<void> updateJobStatus(
    int draftId,
    SyncStatus status, {
    String? errorMessage,
  });
  Future<List<SyncJob>> getJobs();
}
