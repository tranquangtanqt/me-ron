import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/category/category_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const CategoryFormScreen({
    super.key,
    this.id
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(categoryFormNotifierProvider.notifier).initCategoryForm(widget.id);

      final state = ref.read(categoryFormNotifierProvider);
      nameController.text = state.name ?? '';
      descriptionController.text = state.description ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void createCategory() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(categoryFormNotifierProvider.notifier).createCategory();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/category');
      AppSnackBar.show('Thêm mới dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updateCategory() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(categoryFormNotifierProvider.notifier).updatedCategory(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Cập nhật dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteCategory() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(categoryFormNotifierProvider.notifier).deleteCategory(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/category');
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(categoryFormNotifierProvider.notifier);
    final isLoaded = ref.watch(categoryFormNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Thêm danh mục sản phẩn' : 'Chỉnh sửa danh mục sản phẩn'),
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
                  _DescriptionField(
                    controller: descriptionController,
                    onChanged: notifier.onChangedDescription,
                  ),
                  _CreateOrUpdateButton(
                    id: widget.id,
                    onCreateCategory: createCategory,
                    onUpdateCategory: updateCategory,
                  ),
                  _DeleteButton(
                    id: widget.id,
                    onDeleteCategory: deleteCategory,
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

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Mô tả',
        hintText: 'Nhập mo tả...',
        onChanged: onChanged,
      ),
    );
  }
}


class _CreateOrUpdateButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreateCategory;
  final VoidCallback onUpdateCategory;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreateCategory,
    required this.onUpdateCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      categoryFormNotifierProvider.select((s) {
        return (s.name?.isNotEmpty ?? false);
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: id == null ? 'Thêm danh mục sản phẩm' : 'Chỉnh sửa danh mục sản phẩm',
        enabled: isFormValid,
        onTap: () {
          if (id != null) {
            onUpdateCategory();
          } else {
            onCreateCategory();
          }
        },
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeleteCategory;

  const _DeleteButton({
    required this.id,
    required this.onDeleteCategory,
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
              onDeleteCategory();
            },
          );
        },
      ),
    );
  }
}
