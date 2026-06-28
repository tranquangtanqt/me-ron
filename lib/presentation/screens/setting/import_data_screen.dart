import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

// Address → Categories → Users → Products → Orders → Transactions → OrderItems → QueuedActions
class ImportDataScreen extends ConsumerStatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ConsumerState<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends ConsumerState<ImportDataScreen> {
  Future<File?> _resolveImportFile({required String tableName}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv'],
      withData: false,
    );

    if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (await file.exists()) {
        return file;
      }
    }

    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final backupsDirectory = Directory('${appDocumentsDirectory.path}/backups');
    if (!await backupsDirectory.exists()) {
      return null;
    }

    final backupDirectories = <Directory>[];
    await for (final entity in backupsDirectory.list()) {
      if (entity is Directory) {
        backupDirectories.add(entity);
      }
    }

    backupDirectories.sort((a, b) => b.path.compareTo(a.path));

    for (final backupDirectory in backupDirectories) {
      await for (final entity in backupDirectory.list()) {
        if (entity is File) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.startsWith('${tableName.toLowerCase()}_') && fileName.endsWith('.tsv')) {
            return entity;
          }
        }
      }
    }

    return null;
  }

  Future<void> _importTsvToDatabase({
    required BuildContext context,
    required String tableName,
    String? identityColumn,
  }) async {
    try {
      final file = await _resolveImportFile(tableName: tableName);
      if (file == null) {
        throw Exception('Không tìm thấy file TSV phù hợp');
      }

      if (!await file.exists()) {
        throw Exception('File không tồn tại');
      }

      final content = await file.readAsLines();
      if (content.isEmpty) {
        throw Exception('File rỗng');
      }

      final header = content.first.split('\t');
      final rows = content.skip(1).where((line) => line.trim().isNotEmpty).toList();

      final db = DatabaseService.instance.database;
      await db.transaction((txn) async {
        await txn.delete(tableName);

        for (final rowLine in rows) {
          final values = rowLine.split('\t');
          final rowMap = <String, dynamic>{};

          for (var i = 0; i < header.length && i < values.length; i++) {
            final key = header[i].trim();
            final value = values[i].trim();
            if (key.isEmpty) {
              continue;
            }
            rowMap[key] = value;
          }

          if (rowMap.isEmpty) {
            continue;
          }

          await txn.insert(tableName, rowMap);
        }
      });

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
        SnackBar(content: Text('Đã nhập ${rows.length} dòng cho bảng $tableName')),
      );
    } catch (e) {
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nhập dữ liệu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final importTargets = <_ImportTarget>[
      const _ImportTarget(
        tableName: DatabaseConfig.addressTableName,
        title: 'Địa chỉ (Address)',
      ),
      const _ImportTarget(
        tableName: DatabaseConfig.categoriesTableName,
        title: 'Danh mục món ăn (Categories)',
        identityColumn: 'id',
      ),
      const _ImportTarget(
        tableName: DatabaseConfig.userTableName,
        title: 'Khách hàng (Users)',
        identityColumn: 'id',
      ),
      const _ImportTarget(
        tableName: DatabaseConfig.productTableName,
        title: 'Món ăn (Products)',
        identityColumn: 'id',
      ),
      const _ImportTarget(
        tableName: DatabaseConfig.orderTableName,
        title: 'Đơn hàng (Orders)',
        identityColumn: 'id',
      ),
      // const _ImportTarget(
      //   tableName: DatabaseConfig.transactionTableName,
      //   title: 'Giao dịch (Transactions)',
      //   identityColumn: 'id',
      // ),
      const _ImportTarget(
        tableName: DatabaseConfig.orderItemTableName,
        title: 'Chi tiết đơn hàng (OrderItems)',
        identityColumn: 'id',
      ),
      // const _ImportTarget(
      //   tableName: DatabaseConfig.queuedActionTableName,
      //   title: 'Hành động đang chờ (QueuedActions)',
      //   identityColumn: 'id',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nhập dữ liệu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in importTargets)
              _ImportButton(
                onImport: () => _importTsvToDatabase(
                  context: context,
                  tableName: target.tableName,
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

class _ImportTarget {
  final String tableName;
  final String title;
  final String? identityColumn;

  const _ImportTarget({
    required this.tableName,
    required this.title,
    this.identityColumn,
  });
}

class _ImportButton extends StatelessWidget {
  final VoidCallback onImport;
  final String title;

  const _ImportButton({
    required this.onImport,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: onImport,
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



