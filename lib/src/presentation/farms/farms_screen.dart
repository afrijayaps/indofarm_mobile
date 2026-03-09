import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/farms/farm_controller.dart';
import 'recording_list_screen.dart';

class FarmsScreen extends ConsumerWidget {
  const FarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmsAsync = ref.watch(farmsProvider);
    return farmsAsync.when(
      data: (farms) {
        if (farms.isEmpty) {
          return const Center(child: Text('Tidak ada farm'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(farmsProvider.future),
          child: ListView.separated(
            itemCount: farms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final farm = farms[index];
              return ListTile(
                title: Text(farm.name),
                subtitle: Text(farm.location),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecordingListScreen(
                        farmId: farm.id,
                        farmName: farm.name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      error: (error, _) => Center(child: Text('Error: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
