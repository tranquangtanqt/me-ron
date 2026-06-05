import 'package:intl/intl.dart';

import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel {
  int? id;
  int? userId;
  String? userName;
  int? status;
  DateTime? deliveryDatetime;
  int discountValue;
  int subTotal;
  int total;
  String? note;
  String? createdAt;
  String? updatedAt;
  List<OrderItemModel>? items;
  int? orderItemId;
  int? orderId;
  int? productId;
  String? snapshotName;
  int? snapshotPrice;
  int? quantity;
  int? lineTotal;

  OrderModel({
    this.id,
    this.userId,
    this.userName,
    this.status,
    required this.deliveryDatetime,
    required this.discountValue,
    required this.subTotal,
    required this.total,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.orderItemId,
    this.orderId,
    this.productId,
    this.snapshotName,
    this.snapshotPrice,
    this.quantity,
    this.lineTotal,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      status: json['status'],
      deliveryDatetime: json['deliveryDatetime'] != null
          ? DateTime.parse(json['deliveryDatetime'])
          : null,
      discountValue: json['discountValue'] ?? '',
      subTotal: json['subTotal'] ?? '',
      total: json['total'] ?? 0,
      note: json['note'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      orderId: json['orderId'],
      orderItemId: json['orderItemId'],
      productId: json['productId'],
      snapshotName: json['snapshotName'],
      snapshotPrice: json['snapshotPrice'],
      quantity: json['quantity'],
      lineTotal: json['lineTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'deliveryDatetime': deliveryDatetime?.toIso8601String(),
      'discountValue': discountValue,
      'subTotal': subTotal,
      'total': total,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      status: entity.status,
      deliveryDatetime: entity.deliveryDatetime,
      discountValue: entity.discountValue,
      subTotal: entity.subTotal,
      total: entity.total,
      note: entity.note,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      status: status ?? 0,
      deliveryDatetime: deliveryDatetime,
      discountValue: discountValue ?? 0,
      subTotal: subTotal ?? 0,
      total: total ?? 0,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'OrderModel('
        'id: $id, '
        'userId: $userId, '
        'userName: $userName, '
        'status: $status, '
        'deliveryDatetime: $deliveryDatetime, '
        'discountValue: $discountValue, '
        'subTotal: $subTotal, '
        'total: $total, '
        'note: $note, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'orderItemId: $orderItemId, '
        'items: $items, '
        ')\n';
  }
}
