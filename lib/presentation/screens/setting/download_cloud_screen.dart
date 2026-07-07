import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

// Address → Categories → Users → Products → Orders → Transactions → OrderItems → QueuedActions
class DownloadCloudScreen extends ConsumerStatefulWidget {
  const DownloadCloudScreen({super.key});

  @override
  ConsumerState<DownloadCloudScreen> createState() => _DownloadCloudScreenState();
}

class _DownloadCloudScreenState extends ConsumerState<DownloadCloudScreen> {
  Future<void> _downloadDatabaseFromFirebase({
    required BuildContext context,
    required String tableName,
    required String title,
    String? identityColumn,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(tableName);

      // Lấy toàn bộ document của bảng này từ Firestore.
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Không có dữ liệu trên đám mây cho bảng này');
      }

      final db = DatabaseService.instance.database;

      // Xóa dữ liệu cũ của bảng này ở SQLite rồi ghi lại từ dữ liệu tải về.
      await db.transaction((txn) async {
        await txn.delete(tableName);

        for (final doc in snapshot.docs) {
          final rowMap = Map<String, dynamic>.from(doc.data());
          if (rowMap.isEmpty) continue;

          await txn.insert(tableName, rowMap);
        }
      });

      // Cập nhật lại sqlite_sequence để lần thêm mới tiếp theo không bị trùng id.
      if (identityColumn != null) {
        final maxIdResult = await db.rawQuery(
          "SELECT MAX($identityColumn) AS maxId FROM $tableName",
        );
        final maxId = maxIdResult.first['maxId'];
        if (maxId != null) {
          await db.rawDelete("DELETE FROM sqlite_sequence WHERE name = '$tableName'");
          await db.rawInsert(
            "INSERT INTO sqlite_sequence(name, seq) VALUES('$tableName', ?)",
            [maxId],
          );
        }
      }

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tải về ${snapshot.docs.length} dòng cho bảng $title')),
      );
    } catch (e) {
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải dữ liệu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadTargets = <_DownloadTarget>[
      const _DownloadTarget(
        tableName: DatabaseConfig.addressTableName,
        title: 'Địa chỉ (Address)',
        label: 'Địa chỉ',
      ),
      const _DownloadTarget(
        tableName: DatabaseConfig.categoriesTableName,
        title: 'Danh mục món ăn (Categories)',
        label: 'Danh mục món ăn',
        identityColumn: 'id',
      ),
      const _DownloadTarget(
        tableName: DatabaseConfig.userTableName,
        title: 'Khách hàng (Users)',
        label: 'Khách hàng',
        identityColumn: 'id',
      ),
      const _DownloadTarget(
        tableName: DatabaseConfig.productTableName,
        title: 'Món ăn (Products)',
        label: 'Món ăn',
        identityColumn: 'id',
      ),
      const _DownloadTarget(
        tableName: DatabaseConfig.orderTableName,
        title: 'Đơn hàng (Orders)',
        label: 'Đơn hàng',
        identityColumn: 'id',
      ),
      // const _DownloadTarget(
      //   tableName: DatabaseConfig.transactionTableName,
      //   title: 'Giao dịch (Transactions)',
      //   label: 'Giao dịch',
      //   identityColumn: 'id',
      // ),
      const _DownloadTarget(
        tableName: DatabaseConfig.orderItemTableName,
        title: 'Chi tiết đơn hàng (OrderItems)',
        label: 'Chi tiết đơn hàng',
        identityColumn: 'id',
      ),
      // const _DownloadTarget(
      //   tableName: DatabaseConfig.queuedActionTableName,
      //   title: 'Hành động đang chờ (QueuedActions)',
      //   label: 'Hành động đang chờ',
      //   identityColumn: 'id',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tải về máy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in downloadTargets)
              _DownloadButton(
                onDownload: () => _downloadDatabaseFromFirebase(
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

class _DownloadTarget {
  final String tableName;
  final String title;
  final String label;
  final String? identityColumn;

  const _DownloadTarget({
    required this.tableName,
    required this.title,
    required this.label,
    this.identityColumn,
  });
}

class _DownloadButton extends StatelessWidget {
  final VoidCallback onDownload;
  final String title;

  const _DownloadButton({
    required this.onDownload,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: onDownload,
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
