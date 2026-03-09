enum SyncStatus { pending, synced, failed }

class SyncJob {
  const SyncJob({
    required this.id,
    required this.draftId,
    required this.status,
    this.errorMessage,
  });

  final int id;
  final int draftId;
  final SyncStatus status;
  final String? errorMessage;
}
