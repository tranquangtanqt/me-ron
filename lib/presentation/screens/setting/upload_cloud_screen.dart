import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/firestore_batch.dart';
import '../../widgets/app_button.dart';

// Address → Categories → Users → Products → Orders → Transactions → OrderItems → QueuedActions
class UploadCloudScreen extends ConsumerStatefulWidget {
  const UploadCloudScreen({super.key});

  @override
  ConsumerState<UploadCloudScreen> createState() => _UploadCloudScreenState();
}

class _UploadCloudScreenState extends ConsumerState<UploadCloudScreen> {
  Future<void> _uploadDatabaseToFirebase({
    required BuildContext context,
    required String tableName,
    required String title,
    String? identityColumn,
  }) async {
    try {
      final db = DatabaseService.instance.database;
      final rows = await db.query(tableName);

      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(tableName);

      // Xóa toàn bộ document cũ của bảng này trước khi đồng bộ lại.
      await deleteAllDocuments(collection);

      // Đẩy dữ liệu hiện tại của bảng lên Firestore.
      for (final chunk in chunked(rows, firestoreBatchLimit)) {
        final batch = firestore.batch();
        for (final row in chunk) {
          final docId = identityColumn != null ? row[identityColumn]?.toString() : null;
          final docRef = docId != null ? collection.doc(docId) : collection.doc();
          batch.set(docRef, Map<String, dynamic>.from(row));
        }
        await batch.commit();
      }

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tải lên ${rows.length} dòng cho bảng $title')),
      );
    } catch (e) {
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sao lưu dữ liệu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadTargets = <_UploadTarget>[
      const _UploadTarget(
        tableName: DatabaseConfig.addressTableName,
        title: 'Địa chỉ (Address)',
        label: 'Địa chỉ',
      ),
      const _UploadTarget(
        tableName: DatabaseConfig.categoriesTableName,
        title: 'Danh mục món ăn (Categories)',
        label: 'Danh mục món ăn',
        identityColumn: 'id',
      ),
      const _UploadTarget(
        tableName: DatabaseConfig.userTableName,
        title: 'Khách hàng (Users)',
        label: 'Khách hàng',
        identityColumn: 'id',
      ),
      const _UploadTarget(
        tableName: DatabaseConfig.productTableName,
        title: 'Món ăn (Products)',
        label: 'Món ăn',
        identityColumn: 'id',
      ),
      const _UploadTarget(
        tableName: DatabaseConfig.orderTableName,
        title: 'Đơn hàng (Orders)',
        label: 'Đơn hàng',
        identityColumn: 'id',
      ),
      // const _UploadTarget(
      //   tableName: DatabaseConfig.transactionTableName,
      //   title: 'Giao dịch (Transactions)',
      //   label: 'Giao dịch',
      //   identityColumn: 'id',
      // ),
      const _UploadTarget(
        tableName: DatabaseConfig.orderItemTableName,
        title: 'Chi tiết đơn hàng (OrderItems)',
        label: 'Chi tiết đơn hàng',
        identityColumn: 'id',
      ),
      // const _UploadTarget(
      //   tableName: DatabaseConfig.queuedActionTableName,
      //   title: 'Hành động đang chờ (QueuedActions)',
      //   label: 'Hành động đang chờ',
      //   identityColumn: 'id',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tải lên đám mây')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in uploadTargets)
              _UploadButton(
                onUpload: () => _uploadDatabaseToFirebase(
                  context: context,
                  tableName: target.tableName,
                  title: target.label,
                  identityColumn: target.identityColumn,
                ),
                title: target.title,
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadTarget {
  final String tableName;
  final String title;
  final String label;
  final String? identityColumn;

  const _UploadTarget({
    required this.tableName,
    required this.title,
    required this.label,
    this.identityColumn,
  });
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onUpload;
  final String title;

  const _UploadButton({
    required this.onUpload,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: onUpload,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
