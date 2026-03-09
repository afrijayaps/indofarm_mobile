import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/sync/sync_state_machine.dart';
import 'package:indofarm_mobile/src/domain/models/sync_job.dart';

void main() {
  test('pending becomes synced on success', () {
    final next = nextSyncStatus(
      current: SyncStatus.pending,
      requestSucceeded: true,
    );
    expect(next, SyncStatus.synced);
  });

  test('pending becomes failed on failed request', () {
    final next = nextSyncStatus(
      current: SyncStatus.pending,
      requestSucceeded: false,
    );
    expect(next, SyncStatus.failed);
  });
}
