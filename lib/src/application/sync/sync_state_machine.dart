import '../../domain/models/sync_job.dart';

SyncStatus nextSyncStatus({
  required SyncStatus current,
  required bool requestSucceeded,
}) {
  if (requestSucceeded) {
    return SyncStatus.synced;
  }
  if (current == SyncStatus.pending || current == SyncStatus.failed) {
    return SyncStatus.failed;
  }
  return current;
}
