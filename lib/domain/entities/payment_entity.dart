import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final int? id;
  final int? paymentMethod;
  final int amount;
  final DateTime? paymentDate;
  final String? createdAt;
  final String? updatedAt;

  const PaymentEntity({
    this.id,
    this.paymentMethod,
    required this.amount,
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
  });

  PaymentEntity copyWith({
    final int? id,
    final int? paymentMethod,
    final int? amount,
    final int? returnAmount,
    final DateTime? paymentDate,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    paymentMethod,
    amount,
    paymentDate,
    createdAt,
    updatedAt,
  ];
}
