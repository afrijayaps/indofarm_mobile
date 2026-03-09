import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/farm.dart';
import '../providers.dart';

final farmsProvider = FutureProvider<List<Farm>>((ref) async {
  final repo = ref.watch(farmRepositoryProvider);
  return repo.getFarms();
});

final farmSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, farmId) async {
      final repo = ref.watch(farmRepositoryProvider);
      return repo.getFarmSummary(farmId);
    });
