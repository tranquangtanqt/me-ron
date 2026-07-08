import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/firestore_batch.dart';
import '../database/database_service.dart';

class CloudSyncService {
  CloudSyncService._();

  /// Replaces the cloud collection for [tableName] with the current contents of the local table.
  static Future<int> uploadTable({
    required String tableName,
    String? identityColumn,
  }) async {
    final db = DatabaseService.instance.database;
    final rows = await db.query(tableName);

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(tableName);

    await deleteAllDocuments(collection);

    for (final chunk in chunked(rows, firestoreBatchLimit)) {
      final batch = firestore.batch();
      for (final row in chunk) {
        final docId = identityColumn != null ? row[identityColumn]?.toString() : null;
        final docRef = docId != null ? collection.doc(docId) : collection.doc();
        batch.set(docRef, Map<String, dynamic>.from(row));
      }
      await batch.commit();
    }

    return rows.length;
  }

  /// Replaces the local table for [tableName] with the current contents of the cloud collection.
  static Future<int> downloadTable({
    required String tableName,
    String? identityColumn,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(tableName);

    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final db = DatabaseService.instance.database;

    await db.transaction((txn) async {
      await txn.delete(tableName);

      for (final doc in snapshot.docs) {
        final rowMap = Map<String, dynamic>.from(doc.data());
        if (rowMap.isEmpty) continue;

        await txn.insert(tableName, rowMap);
      }
    });

    if (identityColumn != null) {
      final maxIdResult = await db.rawQuery('SELECT MAX($identityColumn) AS maxId FROM $tableName');
      final maxId = maxIdResult.first['maxId'];
      if (maxId != null) {
        await db.rawDelete("DELETE FROM sqlite_sequence WHERE name = '$tableName'");
        await db.rawInsert(
          "INSERT INTO sqlite_sequence(name, seq) VALUES('$tableName', ?)",
          [maxId],
        );
      }
    }

    return snapshot.docs.length;
  }

  /// Deletes every document in the cloud collection for [tableName].
  static Future<int> deleteCloudTable({required String tableName}) async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(tableName);

    return deleteAllDocuments(collection);
  }
}
