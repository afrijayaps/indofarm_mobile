import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/sync_job.dart';
import '../providers.dart';

final syncJobsProvider = FutureProvider<List<SyncJob>>((ref) async {
  return ref.watch(syncRepositoryProvider).getJobs();
});
