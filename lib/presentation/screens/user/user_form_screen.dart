import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/address/address_notifier.dart';
import '../../providers/user/user_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const UserFormScreen({
    super.key,
    this.id
  });

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userFormNotifierProvider.notifier).initUserForm(widget.id);

      final state = ref.read(userFormNotifierProvider);
      nameController.text = state.name ?? '';
      addressController.text = state.address ?? '';
      phoneController.text = state.phone ?? '';
      noteController.text = state.note ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void createUser() async {
    try {
      var res = await AppDialog.showProgress(() {
        return ref.read(userFormNotifierProvider.notifier).createUser();
      });

      if (res.isSuccess) {
        if (!mounted) return;
        context.pop();
        AppSnackBar.show('Thêm mới dữ liệu thành công');
      } else {
        AppDialog.showError(error: res.error?.toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppDialog.showError(error: e.toString());
    }
  }

  void updateUser() async {
    try {
      var res = await AppDialog.showProgress(() {
        return ref.read(userFormNotifierProvider.notifier).updatedUser(widget.id!);
      });

      if (res.isSuccess) {
        if (!mounted) return;
        context.pop();
        AppSnackBar.show('Cập nhật dữ liệu thành công!');
      } else {
        AppDialog.showError(error: res.error?.toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppDialog.showError(error: e.toString());
    }
  }

  void deleteUser() async {
    try {
      var res = await AppDialog.showProgress(() {
        return ref.read(userFormNotifierProvider.notifier).deleteUser(widget.id!);
      });

      if (res.isSuccess) {
        if (!mounted) return;
        context.pop();
        AppSnackBar.show('Xóa dữ liệu thành công!');
      } else {
        AppDialog.showError(error: res.error?.toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppDialog.showError(error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addressNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allAddress}");
    });

    final notifier = ref.read(userFormNotifierProvider.notifier);
    final isLoaded = ref.watch(userFormNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Thêm khách hàng' : 'Chỉnh sửa khách hàng'),
        titleSpacing: 0,
        shadowColor: Colors.transparent,
        actions: [_CreateOrUpdateButton(
          id: widget.id,
          onCreate: createUser,
          onUpdated: updateUser,
        ),],
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameField(
                    controller: nameController,
                    onChanged: notifier.onChangedName,
                  ),
                  _PhoneField(
                    controller: phoneController,
                    onChanged: notifier.onChangedPhone,
                  ),
                  _AddressField(
                    controller: addressController,
                    onChanged: notifier.onChangedAddress,
                  ),
                  _NoteField(
                    controller: noteController,
                    onChanged: notifier.onChangedNote,
                  ),
                  _DeleteButton(
                    id: widget.id,
                    onDeleteUser: deleteUser,
                  ),
                ],
              ),
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

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Số điện thoại',
        hintText: 'Nhập số điện thoại...',
        onChanged: onChanged,
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AddressField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Địa chỉ',
        hintText: 'Nhập địa chỉ...',
        onChanged: onChanged,
      ),
    );
  }
}


class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NoteField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Ghi chú',
        hintText: 'Nhập ghi chú...',
        maxLines: 4,
        onChanged: onChanged,
      ),
    );
  }
}

class _CreateOrUpdateButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreate;
  final VoidCallback onUpdated;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreate,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      userFormNotifierProvider.select((s) {
        return (s.name?.isNotEmpty ?? false);
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
              if (id != null) {
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
  final int? id;
  final VoidCallback onDeleteUser;

  const _DeleteButton({
    required this.id,
    required this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context) {
    if (id == null) return const SizedBox(height: AppSizes.padding * 2);

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
            text: 'Bạn có chắc chắn muốn xóa danh mục?',
            leftButtonText: 'Hủy bỏ',
            rightButtonText: 'Xóa',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onDeleteUser();
            },
          );
        },
      ),
    );
  }
}
