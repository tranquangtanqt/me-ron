import '../../domain/entities/payment_order_entity.dart';

class PaymentOrderModel {
  int? id;
  int paymentId;
  int orderId;
  int paidAmount;
  String? createdAt;
  String? updatedAt;

  PaymentOrderModel({
    this.id,
    required this.paymentId,
    required this.orderId,
    required this.paidAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'],
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      paidAmount: json['paidAmount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'orderId': orderId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PaymentOrderModel.fromEntity(PaymentOrderEntity entity) {
    return PaymentOrderModel(
      id: entity.id,
      paymentId: entity.paymentId,
      orderId: entity.orderId,
      paidAmount: entity.paidAmount,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  PaymentOrderEntity toEntity() {
    return PaymentOrderEntity(
      id: id,
      paymentId: paymentId,
      orderId: orderId,
      paidAmount: paidAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentOrderModel('
        'id: $id, '
        'paymentId: $paymentId, '
        'orderId: $orderId, '
        'paidAmount: $paidAmount, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')\n';
  }
}
