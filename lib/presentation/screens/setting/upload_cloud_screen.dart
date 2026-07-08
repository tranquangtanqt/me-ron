import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud/cloud_sync_service.dart';
import '../../../core/services/cloud/cloud_sync_target.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';

class UploadCloudScreen extends ConsumerStatefulWidget {
  const UploadCloudScreen({super.key});

  @override
  ConsumerState<UploadCloudScreen> createState() => _UploadCloudScreenState();
}

class _UploadCloudScreenState extends ConsumerState<UploadCloudScreen> {
  Future<void> _uploadDatabaseToFirebase({
    required BuildContext context,
    required CloudSyncTarget target,
  }) async {
    try {
      final count = await CloudSyncService.uploadTable(
        tableName: target.tableName,
        identityColumn: target.identityColumn,
      );

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tải lên $count dòng cho bảng ${target.title}')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tải lên đám mây')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final target in cloudSyncTargets)
              _UploadButton(
                onUpload: () => _uploadDatabaseToFirebase(context: context, target: target),
                title: target.title,
              ),
          ],
        ),
      ),
    );
  }
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
