import 'dart:convert';

import '../../core/storage/local_database.dart';
import '../../domain/models/recording.dart';

class RecordingLocalDataSource {
  RecordingLocalDataSource(this._dbFuture);

  final Future<LocalDatabase> _dbFuture;
  static final List<RecordingDraft> _memoryDrafts = <RecordingDraft>[];
  static int _memoryDraftId = 1;

  Future<RecordingDraft> insertDraft(RecordingPayload payload) async {
    final now = DateTime.now().toIso8601String();
    try {
      final db = (await _dbFuture).database;
      final id = await db.insert('recording_drafts', {
        'farm_id': payload.farmId,
        'payload': jsonEncode(payload.toJson()),
        'status': DraftStatus.pending.name,
        'created_at': now,
      });
      return RecordingDraft(
        id: id,
        payload: payload,
        status: DraftStatus.pending,
        createdAt: DateTime.parse(now),
      );
    } catch (_) {
      final draft = RecordingDraft(
        id: _memoryDraftId++,
        payload: payload,
        status: DraftStatus.pending,
        createdAt: DateTime.parse(now),
      );
      _memoryDrafts.insert(0, draft);
      return draft;
    }
  }

  Future<List<RecordingDraft>> getDrafts() async {
    try {
      final db = (await _dbFuture).database;
      final rows = await db.query('recording_drafts', orderBy: 'id DESC');
      return rows.map(_mapRow).toList();
    } catch (_) {
      return List<RecordingDraft>.from(_memoryDrafts);
    }
  }

  Future<List<RecordingDraft>> getDraftsByFarm(int farmId) async {
    try {
      final db = (await _dbFuture).database;
      final rows = await db.query(
        'recording_drafts',
        where: 'farm_id = ?',
        whereArgs: [farmId],
        orderBy: 'id DESC',
      );
      return rows.map(_mapRow).toList();
    } catch (_) {
      return _memoryDrafts.where((d) => d.payload.farmId == farmId).toList();
    }
  }

  Future<void> updateDraftStatus(int draftId, DraftStatus status) async {
    try {
      final db = (await _dbFuture).database;
      await db.update(
        'recording_drafts',
        {'status': status.name},
        where: 'id = ?',
        whereArgs: [draftId],
      );
    } catch (_) {
      final index = _memoryDrafts.indexWhere((d) => d.id == draftId);
      if (index < 0) return;
      final current = _memoryDrafts[index];
      _memoryDrafts[index] = RecordingDraft(
        id: current.id,
        payload: current.payload,
        status: status,
        createdAt: current.createdAt,
      );
    }
  }

  RecordingDraft _mapRow(Map<String, Object?> row) {
    final payload = row['payload']?.toString() ?? '{}';
    final farmId = (row['farm_id'] as num?)?.toInt() ?? 0;
    final data = jsonDecode(payload) as Map<String, dynamic>;

    return RecordingDraft(
      id: (row['id'] as num?)?.toInt() ?? 0,
      payload: RecordingPayload(
        farmId: farmId,
        cageId: (data['cage_id'] as num?)?.toInt() ?? 0,
        tanggal: data['tanggal']?.toString() ?? '',
        pakanPagiKg: (data['pakan_pagi_kg'] as num?)?.toDouble() ?? 0,
        pakanSoreKg: (data['pakan_sore_kg'] as num?)?.toDouble() ?? 0,
        pakanTotalKg: (data['pakan_total_kg'] as num?)?.toDouble(),
        mortalitas: (data['mortalitas'] as num?)?.toInt(),
        suhu: (data['suhu'] as num?)?.toDouble(),
        kelembaban: (data['kelembaban'] as num?)?.toDouble(),
        telurRows: ((data['telur_rows'] as List?) ?? [])
            .map((e) => EggRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      status: DraftStatus.values.byName(row['status']?.toString() ?? 'pending'),
      createdAt: DateTime.parse(
        row['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
