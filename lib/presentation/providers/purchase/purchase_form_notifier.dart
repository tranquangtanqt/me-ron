import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/entities/purchase_item_entity.dart';
import '../../../domain/usecases/purchase_item_usecases.dart';
import '../../../domain/usecases/purchase_usecases.dart';
import '../../screens/purchase/components/purchase_item_form.dart';
import '../base/base_form_notifier.dart';
import 'purchase_notifier.dart';
import 'purchase_form_state.dart';

final purchaseFormNotifierProvider = NotifierProvider.autoDispose<PurchaseFormNotifier, PurchaseFormState>(
  PurchaseFormNotifier.new,
);

class PurchaseFormNotifier extends BaseFormNotifier<PurchaseFormState> {
  @override
  PurchaseFormState build() {
    return const PurchaseFormState();
  }

  Future<void> initPurchaseForm(int? purchaseId) async {
    final now = DateTime.now();

    if (purchaseId == null) {
      state = state.copyWith(
        date: now,
        total: 0,
        isLoaded: true,
      );
      return;
    }

    final purchaseRepository = ref.read(purchaseRepositoryProvider);
    final purchaseItemRepository = ref.read(purchaseItemRepositoryProvider);

    final res = await GetPurchaseUsecase(purchaseRepository).call(purchaseId);

    if (res.isSuccess) {
      final purchase = res.data;

      final itemsRes = await GetPurchaseItemsByPurchaseIdUsecase(purchaseItemRepository).call(purchaseId);
      final items = (itemsRes.data ?? [])
          .map((e) => PurchaseItemForm(id: e.id, name: e.name, price: e.price ?? 0))
          .toList();

      state = state.copyWith(
        date: purchase != null ? (DateTime.tryParse(purchase.date) ?? now) : now,
        total: purchase?.total ?? 0,
        items: items,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createPurchase() async {
    return performCreate(
      execute: () async {
        final purchaseRepository = ref.read(purchaseRepositoryProvider);

        final purchase = PurchaseEntity(
          date: (state.date ?? DateTime.now()).toIso8601String(),
          total: state.total ?? 0,
        );

        final items = <PurchaseItemEntity>[
          for (final item in state.items ?? [])
            PurchaseItemEntity(
              name: item.name,
              price: item.price,
            ),
        ];

        return CreatePurchaseWithItemsUsecase(purchaseRepository).call({
          'purchase': purchase,
          'items': items,
        });
      },
      onSuccess: () => ref.read(purchaseNotifierProvider.notifier).getAllPurchase(true),
    );
  }

  Future<Result<void>> updatedPurchase(int id) async {
    return performUpdate(
      execute: () async {
        final purchaseRepository = ref.read(purchaseRepositoryProvider);

        final purchase = PurchaseEntity(
          id: id,
          date: (state.date ?? DateTime.now()).toIso8601String(),
          total: state.total ?? 0,
        );

        final items = <PurchaseItemEntity>[
          for (final item in state.items ?? [])
            PurchaseItemEntity(
              id: item.id,
              purchaseId: id,
              name: item.name,
              price: item.price,
            ),
        ];

        return UpdatePurchaseWithItemsUsecase(purchaseRepository).call({
          'purchase': purchase,
          'items': items,
        });
      },
      onSuccess: () => ref.read(purchaseNotifierProvider.notifier).getAllPurchase(true),
    );
  }

  Future<Result<void>> deletePurchase(int id) async {
    return performDelete(
      execute: () async {
        final purchaseRepository = ref.read(purchaseRepositoryProvider);
        return DeletePurchaseUsecase(purchaseRepository).call(id);
      },
      onSuccess: () => ref.read(purchaseNotifierProvider.notifier).getAllPurchase(true),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(purchaseNotifierProvider.notifier).getAllPurchase(true);
  }

  void onChangedDate(DateTime value) {
    state = state.copyWith(date: value);
  }

  void addItem() {
    final items = [...?state.items, PurchaseItemForm(price: 0)];

    state = state.copyWith(items: items, total: _calcTotal(items));
  }

  void removeItem(int index) {
    final currentItems = state.items ?? [];

    if (index < 0 || index >= currentItems.length) return;

    final updatedItems = [...currentItems]..removeAt(index);

    state = state.copyWith(items: updatedItems, total: _calcTotal(updatedItems));
  }

  void updateItemName(int index, String name) {
    final items = [...?state.items];

    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(name: name);

    state = state.copyWith(items: items);
  }

  void updateItemPrice(int index, int price) {
    final items = [...?state.items];

    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(price: price);

    state = state.copyWith(items: items, total: _calcTotal(items));
  }

  int _calcTotal(List<PurchaseItemForm> items) {
    int total = 0;

    for (final item in items) {
      total += item.price;
    }

    return total;
  }
}
