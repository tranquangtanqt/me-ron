class OrderItemFormState {
  final int? orderId;
  final int? productId;
  final String? snapshotName;
  final int? snapshotPrice;
  final int? quantity;
  final int? lineTotal;
  final bool isLoaded;

  const OrderItemFormState({
    this.orderId,
    this.productId,
    this.snapshotName,
    this.snapshotPrice,
    this.quantity,
    this.lineTotal,
    this.isLoaded = false,
  });

  OrderItemFormState copyWith({
    int? orderId,
    int? productId,
    String? snapshotName,
    int? snapshotPrice,
    int? quantity,
    int? lineTotal,
    String? note,
    bool? isLoaded,
  }) {
    return OrderItemFormState(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      snapshotName: snapshotName ?? this.snapshotName,
      snapshotPrice: snapshotPrice ?? this.snapshotPrice,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
