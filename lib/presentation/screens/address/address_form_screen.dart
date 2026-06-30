import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/address/address_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final String? code;

  const AddressFormScreen({
    super.key,
    this.code
  });

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(addressFormNotifierProvider.notifier).initAddressForm(widget.code);

      final state = ref.read(addressFormNotifierProvider);
      codeController.text = state.code ?? '';
      nameController.text = state.name ?? '';
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void createAddress() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(addressFormNotifierProvider.notifier).createAddress();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Thêm mới địa chỉ thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updateAddress() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(addressFormNotifierProvider.notifier).updatedAddress(widget.code!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Cập nhật dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteAddress() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(addressFormNotifierProvider.notifier).deleteAddress(widget.code!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(addressFormNotifierProvider.notifier);
    final isLoaded = ref.watch(addressFormNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.code == null ? 'Thêm địa chỉ' : 'Chỉnh sửa địa chỉ'),
        titleSpacing: 0,
        shadowColor: Colors.transparent,
        actions: [_CreateOrUpdateButton(
          code: widget.code,
          onCreate: createAddress,
          onUpdated: updateAddress,
        ),],
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CodeField(
                    controller: codeController,
                    onChanged: notifier.onChangedCode,
                  ),
                  _NameField(
                    controller: nameController,
                    onChanged: notifier.onChangedName,
                  ),
                  _DeleteButton(
                    code: widget.code,
                    onDeleteAddress: deleteAddress,
                  ),
                ],
              ),
            ),
    );
  }
}

class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CodeField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Mã',
        hintText: 'Nhập mã...',
        onChanged: onChanged,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Tên',
        hintText: 'Nhập tên...',
        onChanged: onChanged,
      ),
    );
  }
}

class _CreateOrUpdateButton extends ConsumerWidget {
  final String? code;
  final VoidCallback onCreate;
  final VoidCallback onUpdated;

  const _CreateOrUpdateButton({
    required this.code,
    required this.onCreate,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      addressFormNotifierProvider.select((s) {
        return (s.code?.isNotEmpty ?? false) && (s.name?.isNotEmpty ?? false);
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== SAVE BUTTON =====
          AppButton(
            height: 26,
            borderRadius: BorderRadius.circular(4),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding / 2,
            ),
            buttonColor: Theme.of(context).colorScheme.surfaceContainer,
            onTap: () {
              if (code != null) {
                onUpdated();
              } else {
                onCreate();
              }
            },
            enabled: isFormValid,
            child: Row(
              children: [
                Icon(
                  Icons.save,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  'Lưu',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final String? code;
  final VoidCallback onDeleteAddress;

  const _DeleteButton({
    required this.code,
    required this.onDeleteAddress,
  });

  @override
  Widget build(BuildContext context) {
    if (code == null) return const SizedBox(height: AppSizes.padding * 2);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Xóa',
        textColor: Theme.of(context).colorScheme.error,
        buttonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        onTap: () {
          AppDialog.show(
            title: 'Xác nhận',
            text: 'Bạn có chắc chắn muốn xóa địa chỉ?',
            leftButtonText: 'Hủy bỏ',
            rightButtonText: 'Xóa',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onDeleteAddress();
            },
          );
        },
      ),
    );
  }
}
