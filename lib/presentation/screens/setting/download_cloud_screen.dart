import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud/cloud_sync_service.dart';
import '../../../core/services/cloud/cloud_sync_target.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

class DownloadCloudScreen extends ConsumerStatefulWidget {
  const DownloadCloudScreen({super.key});

  @override
  ConsumerState<DownloadCloudScreen> createState() => _DownloadCloudScreenState();
}

class _DownloadCloudScreenState extends ConsumerState<DownloadCloudScreen> {
  Future<void> _downloadDatabaseFromFirebase({
    required BuildContext context,
    required CloudSyncTarget target,
  }) async {
    try {
      final count = await CloudSyncService.downloadTable(
        tableName: target.tableName,
        identityColumn: target.identityColumn,
      );

      if (count == 0) {
        throw Exception('Không có dữ liệu trên đám mây cho bảng này');
      }

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tải về $count dòng cho bảng ${target.title}')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tải về máy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in cloudSyncTargets)
              _DownloadButton(
                onDownload: () => _downloadDatabaseFromFirebase(context: context, target: target),
                title: target.title,
              ),
          ],
        ),
      ),
    );
  }
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
