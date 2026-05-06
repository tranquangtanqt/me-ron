import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../utilities/console_logger.dart';
import 'database_config.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();

  static DatabaseService get instance => _instance;

  late Database database;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
    }

    // Get the path to the database
    String path = join(await getDatabasesPath(), DatabaseConfig.dbPath);

    if (kDebugMode) {
      // Only for development purpose
      // await dropDatabase(path);
    }

    // Open database
    database = await openDatabase(
      path,
      version: DatabaseConfig.version,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
    );
  }

  // Create tables
  Future<void> _createTables(Database db) async {
    await Future.wait([
      db.execute(DatabaseConfig.createUserTable),
      db.execute(DatabaseConfig.createProductTable),
      db.execute(DatabaseConfig.createTransactionTable),
      db.execute(DatabaseConfig.createOrderedProductTable),
      db.execute(DatabaseConfig.createQueuedActionTable),
      db.execute(DatabaseConfig.createAddressTable),
    ]);
  }

  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute(DatabaseConfig.createAddressTable);
    }

    // future version
    // if (oldVersion < 3) { ... }
  }

  @visibleForTesting
  Future<void> initTestDatabase({required Database testDatabase}) async {
    database = testDatabase;

    // Create tables
    await Future.wait([
      database.execute(DatabaseConfig.createUserTable),
      database.execute(DatabaseConfig.createProductTable),
      database.execute(DatabaseConfig.createTransactionTable),
      database.execute(DatabaseConfig.createOrderedProductTable),
      database.execute(DatabaseConfig.createQueuedActionTable),
    ]);
  }

  Future<void> dropDatabase(String path) async {
    // Check if the database file exists
    File databaseFile = File(path);

    if (await databaseFile.exists()) {
      // Delete the database file
      await databaseFile.delete();

      cw('Database deleted successfully!');
    } else {
      ce('Database does not exist!');
    }
  }
}
