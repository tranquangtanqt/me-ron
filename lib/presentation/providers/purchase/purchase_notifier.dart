import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/params/purchase_params.dart';
import '../../../domain/usecases/purchase_usecases.dart';
import 'purchase_filter_notifier.dart';
import 'purchase_state.dart';

final purchaseNotifierProvider = NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);

class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    return const PurchaseState();
  }

  void resetPurchase() {
    state = const PurchaseState(
      allPurchase: [],
      error: null,
    );
  }

  Future<void> getAllPurchase(
    bool resetDataFlg, {
    int? offset,
    String? contains,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (resetDataFlg == true) {
      state = const PurchaseState(
        allPurchase: [],
        error: null,
      );
    }

    final baseParams = BaseParams(
      orderBy: 'date',
      sortBy: 'DESC',
      offset: offset,
    );

    final params = PurchaseParams(
      base: baseParams,
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
    );

    final purchaseRepository = ref.read(purchaseRepositoryProvider);
    final res = await GetAllPurchaseUsecase(purchaseRepository).call(params);

    if (res.isSuccess) {
      final newData = res.data ?? [];

      if (offset == null) {
        state = state.copyWithGroup(allPurchase: newData);
      } else {
        final current = state.allPurchase ?? [];

        state = state.copyWith(
          allPurchase: [
            ...current,
            ...newData,
          ],
        );
      }
    } else {
      state = state.copyWith();
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }

  Future<void> reload() async {
    final filter = ref.read(purchaseFilterProvider);

    final toDate = DateTime(
      filter.toDate!.year,
      filter.toDate!.month,
      filter.toDate!.day,
      23,
      59,
      59,
      999,
    );

    await getAllPurchase(
      true,
      fromDate: filter.fromDate,
      toDate: toDate,
    );
  }
}
