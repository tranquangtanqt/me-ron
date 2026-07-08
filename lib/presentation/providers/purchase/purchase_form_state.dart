import '../../screens/purchase/components/purchase_item_form.dart';

class PurchaseFormState {
  final DateTime? date;
  final int? total;
  final bool isLoaded;
  final List<PurchaseItemForm>? items;

  const PurchaseFormState({
    this.date,
    this.total,
    this.isLoaded = false,
    this.items,
  });

  PurchaseFormState copyWith({
    DateTime? date,
    int? total,
    bool? isLoaded,
    List<PurchaseItemForm>? items,
  }) {
    return PurchaseFormState(
      date: date ?? this.date,
      total: total ?? this.total,
      isLoaded: isLoaded ?? this.isLoaded,
      items: items ?? this.items,
    );
  }
}
