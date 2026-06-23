import '../../domain/entities/payment_entity.dart';

class PaymentModel {
  int? id;
  int? paymentMethod;
  int amount;
  DateTime? paymentDate;
  String? createdAt;
  String? updatedAt;

  PaymentModel({
    this.id,
    this.paymentMethod,
    required this.amount,
    required this.paymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      amount: json['amount'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      paymentMethod: entity.paymentMethod,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      paymentMethod: paymentMethod,
      amount: amount ?? 0,
      paymentDate: paymentDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel('
        'id: $id, '
        'paymentMethod: $paymentMethod, '
        'amount: $amount, '
        'paymentDate: $paymentDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        ')\n';
  }
}
