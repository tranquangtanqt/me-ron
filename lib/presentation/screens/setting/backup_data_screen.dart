import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

class BackupDataScreen extends ConsumerStatefulWidget {
  const BackupDataScreen({super.key});

  @override
  ConsumerState<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends ConsumerState<BackupDataScreen> {
  final panelController = PanelController();
  static const _mediaStoreChannel = MethodChannel('me_ron/media_store');

  Future<String> _saveFileToDownloads({
    required String fileName,
    required String relativePath,
    required String contents,
  }) async {
    final result = await _mediaStoreChannel.invokeMethod<String>('saveFileToDownloads', {
      'fileName': fileName,
      'relativePath': relativePath,
      'mimeType': 'text/tab-separated-values',
      'bytes': Uint8List.fromList(utf8.encode(contents)),
    });

    if (result == null || result.isEmpty) {
      throw Exception('Không thể lưu file vào thư mục Download');
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _exportDatabaseToTsv(BuildContext context) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final downloadRelativePath = 'Download/MeRon/$timestamp';
      final db = DatabaseService.instance.database;
      final tables = <String>[
        DatabaseConfig.addressTableName,
        DatabaseConfig.userTableName,
        DatabaseConfig.categoriesTableName,
        DatabaseConfig.productTableName,
        DatabaseConfig.orderTableName,
        DatabaseConfig.orderItemTableName,
        DatabaseConfig.transactionTableName,
        DatabaseConfig.queuedActionTableName,
      ];

      final exportedFiles = <String>[];

      for (final tableName in tables) {
        final rows = await db.query(tableName);
        final fileName = '${tableName.toLowerCase()}_$timestamp.tsv';
        final contents = rows.isEmpty
            ? ''
            : () {
                final columns = rows.first.keys.toList();
                final lines = <String>[
                  columns.join('\t'),
                ];

                for (final row in rows) {
                  final sanitized = columns.map((column) {
                    final value = row[column];
                    if (value == null) {
                      return '';
                    }
                    return value.toString().replaceAll('\t', ' ').replaceAll('\n', ' ');
                  }).toList();
                  lines.add(sanitized.join('\t'));
                }

                return lines.join('\n');
              }();

        final savedPath = await _saveFileToDownloads(
          fileName: fileName,
          relativePath: downloadRelativePath,
          contents: contents,
        );
        exportedFiles.add(savedPath);
      }

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xuất ${exportedFiles.length} file vào thư mục Download/MeRon/$timestamp')),
      );
    } catch (e) {
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xuất file thất bại: $e')),
      );
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    try {
      final db = DatabaseService.instance.database;
      final tables = <String>[
        DatabaseConfig.queuedActionTableName,
        DatabaseConfig.orderItemTableName,
        DatabaseConfig.transactionTableName,
        DatabaseConfig.orderTableName,
        DatabaseConfig.productTableName,
        DatabaseConfig.userTableName,
        DatabaseConfig.categoriesTableName,
        DatabaseConfig.addressTableName,
      ];

      await db.transaction((txn) async {
        for (final tableName in tables) {
          await txn.delete(tableName);
        }
      });

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu khỏi các bảng.')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sao lưu dữ liệu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExportButton(onExport: () => _exportDatabaseToTsv(context)),
            _ImportButton(),
            _DeleteButton(onDelete: () => _deleteAllData(context)),
          ],
        ),
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {

  const _ImportButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: () {
          context.go('/setting/backup-data/import');
        },
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
                  'Nhập dữ liệu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback onExport;

  const _ExportButton({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: onExport,
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
                  'Xuất file sao lưu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // const Icon(
            //   Icons.arrow_forward_ios_rounded,
            //   size: 18,
            // ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        onTap: onDelete,
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
                  'Xóa toàn bộ dữ liệu',
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


