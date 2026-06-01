import '../../../data/models/order_item_model.dart';

class OrderItemState {
  final List<OrderItemModel>? allOrderItem;
  final bool isLoadingMore;
  final String? error;

  const OrderItemState({
    this.allOrderItem,
    this.isLoadingMore = false,
    this.error
  });

  OrderItemState copyWith({
    List<OrderItemModel>? allOrderItem,
    bool? isLoadingMore,
    String? error
  }) {
    return OrderItemState(
      allOrderItem: allOrderItem ?? this.allOrderItem,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  OrderItemState copyWithGroup({
    List<OrderItemModel>? allOrderItem,
    bool? isLoadingMore,
    String? error
  }) {
    return OrderItemState(
      allOrderItem: allOrderItem ?? this.allOrderItem,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
