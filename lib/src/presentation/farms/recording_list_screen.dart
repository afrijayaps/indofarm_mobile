import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/farms/farm_controller.dart';
import '../../application/providers.dart';
import '../../domain/models/recording.dart';

class RecordingListScreen extends ConsumerWidget {
  const RecordingListScreen({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  final int farmId;
  final String farmName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(farmSummaryProvider(farmId));
    final draftsAsync = ref.watch(_farmDraftsProvider(farmId));

    return Scaffold(
      appBar: AppBar(title: Text('Recording - $farmName')),
      body: summaryAsync.when(
        data: (summary) {
          return draftsAsync.when(
            data: (drafts) {
              if (summary.isEmpty && drafts.isEmpty) {
                return const Center(child: Text('Belum ada data summary/draft'));
              }

              return ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Summary Server',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Latest recording: ${summary['latest_recording_date'] ?? '-'}',
                          ),
                          Text('Periode: ${summary['period'] ?? '-'}'),
                          Text('Metrics: ${summary['metrics'] ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
                  for (final draft in drafts)
                    ListTile(
                      leading: const Icon(Icons.offline_bolt),
                      title: Text(draft.payload.tanggal),
                      subtitle: Text('Draft (${draft.status.name})'),
                    ),
                ],
              );
            },
            error: (error, _) => Center(child: Text('Error draft: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

final _farmDraftsProvider =
    FutureProvider.family<List<RecordingDraft>, int>((ref, farmId) {
      return ref.watch(farmRepositoryProvider).getDraftsByFarm(farmId);
    });
