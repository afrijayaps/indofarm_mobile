import '../../domain/models/sync_job.dart';
import '../../domain/repositories/sync_repository.dart';
import '../local/sync_local_data_source.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._localDataSource);

  final SyncLocalDataSource _localDataSource;

  @override
  Future<void> upsertPendingJob(int draftId) {
    return _localDataSource.upsertPendingJob(draftId);
  }

  @override
  Future<void> updateJobStatus(
    int draftId,
    SyncStatus status, {
    String? errorMessage,
  }) {
    return _localDataSource.updateJobStatus(
      draftId,
      status,
      errorMessage: errorMessage,
    );
  }

  @override
  Future<List<SyncJob>> getJobs() {
    return _localDataSource.getJobs();
  }
}
