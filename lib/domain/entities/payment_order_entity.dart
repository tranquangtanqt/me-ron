import 'package:equatable/equatable.dart';

class PaymentOrderEntity extends Equatable {
  final int? id;
  final int paymentId;
  final int orderId;
  final int paidAmount;
  final String? createdAt;
  final String? updatedAt;

  const PaymentOrderEntity({
    this.id,
    required this.paymentId,
    required this.orderId,
    required this.paidAmount,
    this.createdAt,
    this.updatedAt,
  });

  PaymentOrderEntity copyWith({
    final int? id,
    final int? paymentId,
    final int? orderId,
    final int? paidAmount,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return PaymentOrderEntity(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    paymentId,
    orderId,
    paidAmount,
    createdAt,
    updatedAt,
  ];
}
