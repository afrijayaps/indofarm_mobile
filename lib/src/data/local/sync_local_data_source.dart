import '../../core/storage/local_database.dart';
import '../../domain/models/sync_job.dart';

class SyncLocalDataSource {
  SyncLocalDataSource(this._dbFuture);

  final Future<LocalDatabase> _dbFuture;
  static final List<SyncJob> _memoryJobs = <SyncJob>[];
  static int _memoryJobId = 1;

  Future<void> upsertPendingJob(int draftId) async {
    try {
      final db = (await _dbFuture).database;
      final existing = await db.query(
        'sync_jobs',
        where: 'draft_id = ?',
        whereArgs: [draftId],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('sync_jobs', {
          'draft_id': draftId,
          'status': SyncStatus.pending.name,
          'error_message': null,
        });
        return;
      }

      await db.update(
        'sync_jobs',
        {'status': SyncStatus.pending.name, 'error_message': null},
        where: 'draft_id = ?',
        whereArgs: [draftId],
      );
    } catch (_) {
      final index = _memoryJobs.indexWhere((j) => j.draftId == draftId);
      if (index < 0) {
        _memoryJobs.insert(
          0,
          SyncJob(
            id: _memoryJobId++,
            draftId: draftId,
            status: SyncStatus.pending,
          ),
        );
      } else {
        final current = _memoryJobs[index];
        _memoryJobs[index] = SyncJob(
          id: current.id,
          draftId: current.draftId,
          status: SyncStatus.pending,
        );
      }
    }
  }

  Future<void> updateJobStatus(
    int draftId,
    SyncStatus status, {
    String? errorMessage,
  }) async {
    try {
      final db = (await _dbFuture).database;
      await db.update(
        'sync_jobs',
        {
          'status': status.name,
          'error_message': errorMessage,
        },
        where: 'draft_id = ?',
        whereArgs: [draftId],
      );
    } catch (_) {
      final index = _memoryJobs.indexWhere((j) => j.draftId == draftId);
      if (index < 0) return;
      final current = _memoryJobs[index];
      _memoryJobs[index] = SyncJob(
        id: current.id,
        draftId: current.draftId,
        status: status,
        errorMessage: errorMessage,
      );
    }
  }

  Future<List<SyncJob>> getJobs() async {
    try {
      final db = (await _dbFuture).database;
      final rows = await db.query('sync_jobs', orderBy: 'id DESC');
      return rows
          .map(
            (row) => SyncJob(
              id: (row['id'] as num?)?.toInt() ?? 0,
              draftId: (row['draft_id'] as num?)?.toInt() ?? 0,
              status: SyncStatus.values.byName(
                row['status']?.toString() ?? SyncStatus.pending.name,
              ),
              errorMessage: row['error_message']?.toString(),
            ),
          )
          .toList();
    } catch (_) {
      return List<SyncJob>.from(_memoryJobs);
    }
  }
}
