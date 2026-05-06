import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/database/database_service.dart';
import '../../core/services/info/device_info_service.dart';
import '../../core/services/logger/error_logger_service.dart';
import '../../core/services/printer/printer_service.dart';
import '../../data/datasources/local/product_local_datasource_impl.dart';
import '../../data/datasources/local/queued_action_local_datasource_impl.dart';
import '../../data/datasources/local/transaction_local_datasource_impl.dart';
import '../../data/datasources/local/user_local_datasource_impl.dart';
import '../../data/datasources/local/address_local_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/queued_action_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../routes/app_routes.dart';

// Startup overrides
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden at app startup.'),
);

// Third parties
final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>((ref) => DeviceInfoPlugin());

// Routes
final appRoutesProvider = Provider<AppRoutes>((ref) => AppRoutes(ref));

// Services
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);
final deviceInfoServiceProvider = Provider<DeviceInfoService>(
  (ref) => DeviceInfoService(ref.watch(deviceInfoPluginProvider)),
);
final printerServiceProvider = Provider<PrinterService>(
  (ref) => PrinterService(ref.watch(sharedPreferencesProvider)),
);

// Datasources
// Local Datasources
final productLocalDatasourceProvider = Provider<ProductLocalDatasourceImpl>(
  (ref) => ProductLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasourceImpl>(
  (ref) => TransactionLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final userLocalDatasourceProvider = Provider<UserLocalDatasourceImpl>(
  (ref) => UserLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final addressLocalDatasourceProvider = Provider<AddressLocalDatasourceImpl>(
      (ref) => AddressLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final queuedActionLocalDatasourceProvider = Provider<QueuedActionLocalDatasourceImpl>(
  (ref) => QueuedActionLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);

// Repositories
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    productLocalDatasource: ref.watch(productLocalDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    transactionLocalDatasource: ref.watch(transactionLocalDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    userLocalDatasource: ref.watch(userLocalDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final addressRepositoryProvider = Provider<AddressRepository>(
      (ref) => AddressRepositoryImpl(
    addressLocalDatasource: ref.watch(addressLocalDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final queuedActionRepositoryProvider = Provider<QueuedActionRepository>(
  (ref) => QueuedActionRepositoryImpl(
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
