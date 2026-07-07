import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore batched writes are capped at 500 operations.
const firestoreBatchLimit = 500;

List<List<T>> chunked<T>(List<T> items, int size) {
  return [
    for (var i = 0; i < items.length; i += size) items.sublist(i, i + size > items.length ? items.length : i + size),
  ];
}

/// Deletes every document currently in [collection], batched to stay under
/// Firestore's per-batch operation limit.
Future<int> deleteAllDocuments(CollectionReference<Map<String, dynamic>> collection) async {
  final existingDocs = await collection.get();

  for (final chunk in chunked(existingDocs.docs, firestoreBatchLimit)) {
    final batch = collection.firestore.batch();
    for (final doc in chunk) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  return existingDocs.docs.length;
}
