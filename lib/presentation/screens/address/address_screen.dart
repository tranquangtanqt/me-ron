import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';
import '../../providers/address/address_notifier.dart';
import '../../providers/address/address_form_notifier.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(addressNotifierProvider.notifier).getAllAddress();
    });
  }

  void updateAddress(String code) {
    context.push('/address/address-edit/$code');
  }

  void deleteAddress(String code) async {
    var res = await AppDialog.showProgress(() {
      return ref.read(addressFormNotifierProvider.notifier).deleteAddress(code);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/address');
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

    final allAddress = ref.watch(addressNotifierProvider.select((s) => s.allAddress));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ'),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Mã')),
                    DataColumn(label: Text('Tên')),
                    DataColumn(label: Text('Tùy chọn')),
                  ],
                  rows: (allAddress ?? []).map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.code.toString())),
                        DataCell(Text(item.name ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  updateAddress(item.code);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  AppDialog.show(
                                    title: 'Xác nhận',
                                    text: 'Bạn có chắc chắn muốn xóa địa chỉ?',
                                    leftButtonText: 'Hủy bỏ',
                                    rightButtonText: 'Xóa',
                                    rightButtonColor: Theme.of(context).colorScheme.errorContainer,
                                    rightButtonTextColor: Theme.of(context).colorScheme.error,
                                    onTapRightButton: (context) async {
                                      context.pop();
                                      deleteAddress(item.code);
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
        onTap: () => context.push('/address/address-create'),
      ),
    );
  }
}