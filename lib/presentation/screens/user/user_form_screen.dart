import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/address/address_notifier.dart';
import '../../providers/category/category_notifier.dart';
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
    var res = await AppDialog.showProgress(() {
      return ref.read(userFormNotifierProvider.notifier).createUser();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      // context.go('/user');
      context.pop();
      AppSnackBar.show('Thêm mới dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updateUser() async {
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
  }

  void deleteUser() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(userFormNotifierProvider.notifier).deleteUser(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/user');
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
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
                  _CreateOrUpdateButton(
                    id: widget.id,
                    onCreateUser: createUser,
                    onUpdateUser: updateUser,
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
  final VoidCallback onCreateUser;
  final VoidCallback onUpdateUser;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreateUser,
    required this.onUpdateUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      userFormNotifierProvider.select((s) {
        return (s.name?.isNotEmpty ?? false);
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: id == null ? 'Thêm khách hàng' : 'Chỉnh sửa khách hàng',
        enabled: isFormValid,
        onTap: () {
          if (id != null) {
            onUpdateUser();
          } else {
            onCreateUser();
          }
        },
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
