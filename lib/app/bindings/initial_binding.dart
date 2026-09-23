import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/utils/logger.dart';
import '../../data/datasources/tflite_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/datasources/supabase_scan_datasource.dart';
import '../../data/datasources/supabase_storage_datasource.dart';
import '../../data/repositories/grading_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/local/database.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // 1. Local database (Drift/SQLite) — single source of truth
    final database = AppDatabase();
    Get.put<AppDatabase>(database, permanent: true);

    // 2. Secure storage for auth sessions
    const secureStorage = FlutterSecureStorage();
    Get.put<FlutterSecureStorage>(secureStorage, permanent: true);

    // 3. Supabase client (singleton)
    final supabaseClient = Supabase.instance.client;
    Get.put<SupabaseClient>(supabaseClient, permanent: true);

    // 4. Supabase datasources
    Get.put<SupabaseAuthDatasource>(
      SupabaseAuthDatasource(
        client: supabaseClient,
        secureStorage: secureStorage,
      ),
      permanent: true,
    );

    Get.put<SupabaseScanDatasource>(
      SupabaseScanDatasource(client: supabaseClient),
      permanent: true,
    );

    Get.put<SupabaseStorageDatasource>(
      SupabaseStorageDatasource(client: supabaseClient),
      permanent: true,
    );

    // 5. Auth repository
    final authRepository = AuthRepository(
      authDatasource: Get.find<SupabaseAuthDatasource>(),
    );
    Get.put<AuthRepository>(authRepository, permanent: true);

    // 6. Connectivity service
    final connectivityService = ConnectivityService();
    Get.put<ConnectivityService>(connectivityService, permanent: true);

    // 7. Sync service
    final syncService = SyncService(
      database: Get.find<AppDatabase>(),
      scanDatasource: Get.find<SupabaseScanDatasource>(),
      storageDatasource: Get.find<SupabaseStorageDatasource>(),
      authRepository: authRepository,
      connectivityService: connectivityService,
    );
    Get.put<SyncService>(syncService, permanent: true);

    // 8. Wire sync service → auth repository
    authRepository.setSyncService(syncService);
    authRepository.setDatabase(Get.find<AppDatabase>());

    // 9. TFLite model
    final tflite = TFLiteDataSource();
    if (!GetPlatform.isWeb) {
      await tflite.load();
    } else {
      AppLogger.d('Skipping native model load on web: browser inference is disabled.');
    }
    Get.put<TFLiteDataSource>(tflite, permanent: true);

    // 10. Grading repository
    Get.put<GradingRepository>(
      GradingRepository(
        Get.find<TFLiteDataSource>(),
        Get.find<AppDatabase>(),
      ),
      permanent: true,
    );

    // 11. History repository (Drift DB + cloud sync)
    final historyRepository = HistoryRepository(
      Get.find<AppDatabase>(),
      supabaseScanDatasource: Get.find<SupabaseScanDatasource>(),
    );
    Get.put<HistoryRepository>(historyRepository, permanent: true);

    // 12. Wire sync service → history repository
    historyRepository.setSyncService(syncService);
  }
}
