import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/database_config.dart';
import '../database/database_service.dart';

class BackupExportResult {
  final Map<String, String> fileContents;
  final String timestamp;

  const BackupExportResult({
    required this.fileContents,
    required this.timestamp,
  });
}

class BackupService {
  BackupService._();

  static const _mediaStoreChannel = MethodChannel('me_ron/media_store');

  /// Exports every backed-up table to a `.tsv` file under `Download/MeRon/<timestamp>`.
  static Future<BackupExportResult> exportToLocal() async {
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
      DatabaseConfig.purchaseTableName,
      DatabaseConfig.purchaseItemTableName,
      // DatabaseConfig.transactionTableName,
      // DatabaseConfig.queuedActionTableName,
    ];

    final fileContents = <String, String>{};

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

      await _saveFileToDownloads(
        fileName: fileName,
        relativePath: downloadRelativePath,
        contents: contents,
      );
      fileContents[fileName] = contents;
    }

    return BackupExportResult(fileContents: fileContents, timestamp: timestamp);
  }

  static Future<String> _saveFileToDownloads({
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
}
