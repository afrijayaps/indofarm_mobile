import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/recordings/recording_controller.dart';
import '../../application/sync/sync_controller.dart';

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(recordingDraftsProvider);
    final jobsAsync = ref.watch(syncJobsProvider);

    return draftsAsync.when(
      data: (drafts) {
        return jobsAsync.when(
          data: (jobs) {
            if (drafts.isEmpty) {
              return const Center(child: Text('Belum ada draft sync'));
            }
            final statusByDraft = {for (final job in jobs) job.draftId: job.status};
            final errorByDraft = {
              for (final job in jobs)
                if (job.errorMessage != null) job.draftId: job.errorMessage!,
            };

            return ListView.builder(
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final draft = drafts[index];
                final syncStatus = statusByDraft[draft.id]?.name ?? 'unknown';
                final syncError = errorByDraft[draft.id];

                return ListTile(
                  title: Text('${draft.payload.tanggal} - Farm ${draft.payload.farmId}'),
                  subtitle: Text('Draft: ${draft.status.name} | Sync: $syncStatus'),
                  trailing: TextButton(
                    onPressed: () async {
                      await ref
                          .read(recordingControllerProvider.notifier)
                          .retryDraft(draft);
                      ref.invalidate(recordingDraftsProvider);
                      ref.invalidate(syncJobsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                  isThreeLine: syncError != null,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  minVerticalPadding: 8,
                  subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                );
              },
            );
          },
          error: (error, _) => Center(child: Text('Error sync: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) => Center(child: Text('Error draft: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
