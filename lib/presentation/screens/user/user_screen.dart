import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';
import '../../providers/user/user_notifier.dart';
import '../../providers/user/user_form_notifier.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(userNotifierProvider.notifier).getAllUser();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search() {
    FocusScope.of(context).unfocus();
    setState(() {
      searchQuery = searchController.text.trim().toLowerCase();
    });
  }

  void updateUser(int id) {
    context.push('/user/user-edit/$id');
  }

  void deleteUser(int id) async {
    var res = await AppDialog.showProgress(() {
      return ref.read(userFormNotifierProvider.notifier).deleteUser(id);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      ref.read(userNotifierProvider.notifier).getAllUser();
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allUser}");
    });

    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser));

    final filteredUser = searchQuery.isEmpty
        ? allUser
        : allUser?.where((u) => (u.name ?? '').toLowerCase().contains(searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khách hàng'),
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
              _SearchBar(controller: searchController, onSearch: search),
              const SizedBox(height: AppSizes.padding),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false, //ẩn checkbox
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
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'STT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tên',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Số ĐT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Địa chỉ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // DataColumn(label: Text('Tùy chọn')),
                  ],
                  rows: (filteredUser ?? []).map((item) {
                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          updateUser(item.id!);
                        }
                      },
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(item.id.toString()),
                          ),
                        ),
                        DataCell(Text(item.name ?? '')),
                        DataCell(Text(item.phone ?? '')),
                        DataCell(Text(item.address ?? '')),
                        // DataCell(
                        //   Row(
                        //     children: [
                        //       IconButton(
                        //         icon: const Icon(Icons.edit, color: Colors.orange),
                        //         onPressed: () {
                        //           updateUser(item.id!);
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: const Icon(Icons.delete, color: Colors.red),
                        //         onPressed: () {
                        //           AppDialog.show(
                        //             title: 'Xác nhận',
                        //             text: 'Bạn có chắc chắn muốn xóa dữ liệu?',
                        //             leftButtonText: 'Hủy bỏ',
                        //             rightButtonText: 'Xóa',
                        //             rightButtonColor: Theme.of(context).colorScheme.errorContainer,
                        //             rightButtonTextColor: Theme.of(context).colorScheme.error,
                        //             onTapRightButton: (context) async {
                        //               context.pop();
                        //               deleteUser(item.id!);
                        //             },
                        //           );
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên khách hàng...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onSearch,
            child: const Icon(Icons.search, size: 18),
          ),
        ),
      ],
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
        onTap: () => context.push('/user/user-create'),
      ),
    );
  }
}
