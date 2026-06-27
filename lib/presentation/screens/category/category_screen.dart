import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/category/category_form_notifier.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
    });
  }

  void updateCategory(int id) {
    context.push('/category/category-edit/$id');
  }

  void deleteCategory(int id) async {
    var res = await AppDialog.showProgress(() {
      return ref.read(categoryFormNotifierProvider.notifier).deleteCategory(id);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      // context.go('/category');
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(categoryNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allCategory}");
    });

    final allCategory = ref.watch(categoryNotifierProvider.select((s) => s.allCategory));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục món ăn'),
        titleSpacing: 0,
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.padding),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 25, // giảm khoảng cách giữa các cột
                  horizontalMargin: 8,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 48,
                  dividerThickness: 0, // tắt line mặc định
                  // border: TableBorder.all(
                  //   color: Colors.grey,
                  //   width: 1,
                  // ),
                  columns: const [
                    DataColumn(label: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('STT', style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),),
                    DataColumn(label: Text('Tên', style: TextStyle(fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Tùy chọn', style: TextStyle(fontWeight: FontWeight.bold,))),
                  ],
                  rows: (allCategory ?? []).map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(item.id.toString()),
                        ),),
                        DataCell(Text(item.name ?? '')),
                        DataCell(Text(item.description ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  updateCategory(item.id!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  AppDialog.show(
                                    title: 'Xác nhận',
                                    text: 'Bạn có chắc chắn muốn xóa dữ liệu?',
                                    leftButtonText: 'Hủy bỏ',
                                    rightButtonText: 'Xóa',
                                    rightButtonColor: Theme.of(context).colorScheme.errorContainer,
                                    rightButtonTextColor: Theme.of(context).colorScheme.error,
                                    onTapRightButton: (context) async {
                                      context.pop();
                                      deleteCategory(item.id!);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Thêm',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => context.push('/category/category-create'),
      ),
    );
  }
}