import '../../../data/models/purchase_item_model.dart';
import '../../../data/models/purchase_model.dart';

class PurchaseState {
  final List<PurchaseModel>? allPurchase;
  final String? error;

  const PurchaseState({
    this.allPurchase,
    this.error,
  });

  PurchaseState copyWith({
    List<PurchaseModel>? allPurchase,
    String? error,
  }) {
    return PurchaseState(
      allPurchase: allPurchase ?? this.allPurchase,
      error: error ?? this.error,
    );
  }

  PurchaseState copyWithGroup({
    List<PurchaseModel>? allPurchase,
    String? error,
  }) {
    final Map<int, PurchaseModel> map = {};

    final source = allPurchase ?? [];

    for (final row in source) {
      final purchaseId = row.id!;

      map.putIfAbsent(
        purchaseId,
        () => PurchaseModel(
          id: row.id,
          date: row.date,
          total: row.total,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          items: <PurchaseItemModel>[],
        ),
      );

      if (row.purchaseItemId != null) {
        map[purchaseId]!.items = [
          ...?map[purchaseId]!.items,
          PurchaseItemModel(
            id: row.purchaseItemId,
            purchaseId: purchaseId,
            name: row.itemName,
            price: row.itemPrice ?? 0,
          ),
        ];
      }
    }

    return PurchaseState(
      allPurchase: map.values.toList(),
      error: error ?? this.error,
    );
  }
}
