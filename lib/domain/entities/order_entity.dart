import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final int? id;
  final int? userId;
  final int status;
  final DateTime? deliveryDatetime;
  final DateTime? paymentDatetime;
  final int discountValue;
  final int subTotal;
  final int total;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  const OrderEntity({
    this.id,
    this.userId,
    required this.status,
    this.deliveryDatetime,
    this.paymentDatetime,
    required this.discountValue,
    required this.subTotal,
    required this.total,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  OrderEntity copyWith({
    final int? id,
    final int? userId,
    final int? status,
    final DateTime? deliveryDatetime,
    final DateTime? paymentDatetime,
    final int? discountValue,
    final int? subTotal,
    final int? total,
    final String? note,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      deliveryDatetime: deliveryDatetime ?? this.deliveryDatetime,
      paymentDatetime: paymentDatetime ?? this.paymentDatetime,
      discountValue: discountValue ?? this.discountValue,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    deliveryDatetime,
    paymentDatetime,
    discountValue,
    subTotal,
    total,
    note,
    createdAt,
    updatedAt,
  ];
}
