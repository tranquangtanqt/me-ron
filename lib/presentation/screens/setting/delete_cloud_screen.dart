import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/database/database_config.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/firestore_batch.dart';
import '../../widgets/app_button.dart';

// Address → Categories → Users → Products → Orders → Transactions → OrderItems → QueuedActions
class DeleteCloudScreen extends ConsumerStatefulWidget {
  const DeleteCloudScreen({super.key});

  @override
  ConsumerState<DeleteCloudScreen> createState() => _DeleteCloudScreenState();
}

class _DeleteCloudScreenState extends ConsumerState<DeleteCloudScreen> {
  Future<void> _deleteDataFromFirebase({
    required BuildContext context,
    required String tableName,
    required String title,
    String? identityColumn,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(tableName);

      final deletedCount = await deleteAllDocuments(collection);

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa $deletedCount dòng khỏi bảng $title')),
      );
    } catch (e) {
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa dữ liệu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final importTargets = <_DeleteTarget>[
      const _DeleteTarget(
        tableName: DatabaseConfig.addressTableName,
        title: 'Địa chỉ (Address)',
        label: 'Địa chỉ',
      ),
      const _DeleteTarget(
        tableName: DatabaseConfig.categoriesTableName,
        title: 'Danh mục món ăn (Categories)',
        label: 'Danh mục món ăn',
        identityColumn: 'id',
      ),
      const _DeleteTarget(
        tableName: DatabaseConfig.userTableName,
        title: 'Khách hàng (Users)',
        label: 'Khách hàng',
        identityColumn: 'id',
      ),
      const _DeleteTarget(
        tableName: DatabaseConfig.productTableName,
        title: 'Món ăn (Products)',
        label: 'Món ăn',
        identityColumn: 'id',
      ),
      const _DeleteTarget(
        tableName: DatabaseConfig.orderTableName,
        title: 'Đơn hàng (Orders)',
        label: 'Đơn hàng',
        identityColumn: 'id',
      ),
      // const _DeleteTarget(
      //   tableName: DatabaseConfig.transactionTableName,
      //   title: 'Giao dịch (Transactions)',
      //   label: 'Giao dịch',
      //   identityColumn: 'id',
      // ),
      const _DeleteTarget(
        tableName: DatabaseConfig.orderItemTableName,
        title: 'Chi tiết đơn hàng (OrderItems)',
        label: 'Chi tiết đơn hàng',
        identityColumn: 'id',
      ),
      // const _DeleteTarget(
      //   tableName: DatabaseConfig.queuedActionTableName,
      //   title: 'Hành động đang chờ (QueuedActions)',
      //   label: 'Hành động đang chờ',
      //   identityColumn: 'id',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Xóa dữ liệu đám mây')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in importTargets)
              _DeleteButton(
                onDelete: () => _deleteDataFromFirebase(
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

class _DeleteTarget {
  final String tableName;
  final String title;
  final String label;
  final String? identityColumn;

  const _DeleteTarget({
    required this.tableName,
    required this.title,
    required this.label,
    this.identityColumn,
  });
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  final String title;

  const _DeleteButton({
    required this.onDelete,
    required this.title,
  });

  Future<void> _showConfirmDialog(BuildContext context) async {
    final confirmFirst = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa dữ liệu'),
        content: Text('Bạn có chắc chắn muốn xóa dữ liệu "$title" trên đám mây không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmFirst != true) return;

    if (!context.mounted) return;

    final confirmSecond = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận lần thứ 2'),
        content: Text(
          'Hành động này KHÔNG THỂ HOÀN TÁC.\n\n'
          'Toàn bộ dữ liệu "$title" trên đám mây sẽ bị xóa vĩnh viễn. '
          'Bạn chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirmSecond == true && context.mounted) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: () => _showConfirmDialog(context),
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
