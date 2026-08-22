import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/auth/auth_notifier.dart';
import '../../providers/backup/auto_export_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../providers/theme/theme_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            _UserInfo(),
            _ThemeButton(),
            _AutoExportButton(),
            _BackupPasswordButton(),
            _BackupButton(),
            // _PrinterSettingsButton(),
            // _AboutButton(),
            // _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class _UserInfo extends ConsumerWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
      child: Column(
        children: [
          // AppImage(
          //   image: user?.imageUrl ?? '',
          //   width: 120,
          //   height: 120,
          //   borderRadius: BorderRadius.circular(100),
          //   backgroundColor: Theme.of(context).colorScheme.surface,
          // ),
          // const SizedBox(height: AppSizes.padding),
          Text(
            user?.name ?? '(Mẹ Rôn)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.padding / 4),
          Text(
            user?.address ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.format_paint_outlined,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Thay đổi chủ đề',
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
        onTap: () {
          AppDialog.show(
            title: 'Chủ đề',
            leftButtonText: 'Đóng',
            child: const _ThemeDialogBody(),
          );
        },
      ),
    );
  }
}

class _AutoExportButton extends StatelessWidget {
  const _AutoExportButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Giờ tự động sao lưu',
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
        onTap: () {
          AppDialog.show(
            title: 'Giờ tự động sao lưu',
            leftButtonText: 'Đóng',
            child: const _AutoExportDialogBody(),
          );
        },
      ),
    );
  }
}

class _BackupPasswordButton extends ConsumerWidget {
  const _BackupPasswordButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Mật khẩu sao lưu',
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
        onTap: () {
          final controller = TextEditingController();

          AppDialog.show(
            title: 'Mật khẩu sao lưu',
            leftButtonText: 'Hủy',
            rightButtonText: 'Xác nhận',
            child: _BackupPasswordDialogBody(controller: controller),
            onTapRightButton: (dialogContext) {
              ref.read(autoExportNotifierProvider.notifier).verifyBackupPassword(controller.text);
              Navigator.of(dialogContext).pop();
            },
          );
        },
      ),
    );
  }
}

class _BackupPasswordDialogBody extends StatelessWidget {
  final TextEditingController controller;

  const _BackupPasswordDialogBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Nhập mật khẩu',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _BackupButton extends StatelessWidget {
  const _BackupButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Sao lưu',
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
        onTap: () {
          context.go('/setting/backup-data');
        },
      ),
    );
  }
}

class _PrinterSettingsButton extends StatelessWidget {
  const _PrinterSettingsButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.print_outlined,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Printer Settings',
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
        onTap: () {
          context.go('/account/printer-settings');
        },
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  const _AboutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'About',
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
        onTap: () {
          context.go('/account/about');
        },
      ),
    );
  }
}

class _AutoExportDialogBody extends ConsumerWidget {
  const _AutoExportDialogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoExportState = ref.watch(autoExportNotifierProvider);
    final label = autoExportState.isConfigured
        ? '${autoExportState.hour!.toString().padLeft(2, '0')}:${autoExportState.minute!.toString().padLeft(2, '0')}'
        : 'Chưa thiết lập';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.padding),
        AppButton(
          text: 'Chọn giờ',
          onTap: () async {
            final initialTime = TimeOfDay(
              hour: autoExportState.hour ?? 22,
              minute: autoExportState.minute ?? 0,
            );
            final picked = await showTimePicker(context: context, initialTime: initialTime);

            if (picked == null) return;

            await ref
                .read(autoExportNotifierProvider.notifier)
                .changeTime(
                  hour: picked.hour,
                  minute: picked.minute,
                );
          },
        ),
      ],
    );
  }
}

class _ThemeDialogBody extends ConsumerWidget {
  const _ThemeDialogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return Row(
      children: [
        Switch(
          value: !themeState.isLight,
          onChanged: (val) {
            ref.read(themeNotifierProvider.notifier).changeBrightness(!val);
          },
        ),
        const SizedBox(width: AppSizes.padding),
        Text(
          'Chế độ tối',
          // 'Dark Mode',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
