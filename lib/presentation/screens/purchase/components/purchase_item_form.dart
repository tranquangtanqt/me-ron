class PurchaseItemForm {
  int? id;
  String? name;
  int price;

  PurchaseItemForm({
    this.id,
    this.name,
    this.price = 0,
  });

  PurchaseItemForm copyWith({
    int? id,
    String? name,
    int? price,
  }) {
    return PurchaseItemForm(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}
