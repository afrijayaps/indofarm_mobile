import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_database.dart';
import '../core/storage/session_storage.dart';
import '../core/storage/theme_storage.dart';
import '../core/storage/token_store.dart';
import '../data/local/recording_local_data_source.dart';
import '../data/local/sync_local_data_source.dart';
import '../data/remote/auth_api.dart';
import '../data/remote/farm_api.dart';
import '../data/remote/recording_api.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/farm_repository_impl.dart';
import '../data/repositories/recording_repository_impl.dart';
import '../data/repositories/sync_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/farm_repository.dart';
import '../domain/repositories/recording_repository.dart';
import '../domain/repositories/sync_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(),
);
final themeStorageProvider = Provider<ThemeStorage>((ref) => ThemeStorage());

final databaseProvider = Provider<Future<LocalDatabase>>((ref) {
  return LocalDatabase.open();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  return ApiClient(
    client: ref.watch(httpClientProvider),
    config: appConfig,
    readToken: () => tokenStore.token,
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final farmApiProvider = Provider<FarmApi>((ref) {
  return FarmApi(ref.watch(apiClientProvider));
});

final recordingApiProvider = Provider<RecordingApi>((ref) {
  return RecordingApi(ref.watch(apiClientProvider));
});

final recordingLocalDataSourceProvider = Provider<RecordingLocalDataSource>((
  ref,
) {
  return RecordingLocalDataSource(ref.watch(databaseProvider));
});

final syncLocalDataSourceProvider = Provider<SyncLocalDataSource>((ref) {
  return SyncLocalDataSource(ref.watch(databaseProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authApi: ref.watch(authApiProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
  );
});

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(
    farmApi: ref.watch(farmApiProvider),
    recordingLocalDataSource: ref.watch(recordingLocalDataSourceProvider),
  );
});

final recordingRepositoryProvider = Provider<RecordingRepository>((ref) {
  return RecordingRepositoryImpl(
    recordingApi: ref.watch(recordingApiProvider),
    localDataSource: ref.watch(recordingLocalDataSourceProvider),
  );
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(ref.watch(syncLocalDataSourceProvider));
});
