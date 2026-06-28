import 'package:intl/intl.dart';

import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

int _parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class OrderModel {
  int? id;
  int? userId;
  String? userName;
  int? status;
  DateTime? deliveryDatetime;
  DateTime? paymentDatetime;
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
    required this.paymentDatetime,
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
    final dynamic itemsJson = json['items'];
    final bool hasFlatItemFields = json['orderItemId'] != null ||
        json['productId'] != null ||
        json['snapshotName'] != null ||
        json['quantity'] != null ||
        json['lineTotal'] != null;

    final List<OrderItemModel>? parsedItems = itemsJson is List
        ? itemsJson
            .whereType<Map>()
            .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : hasFlatItemFields
            ? [
                OrderItemModel(
                  id: json['orderItemId'],
                  orderId: json['orderId'],
                  productId: _parseIntValue(json['productId']),
                  snapshotName: json['snapshotName']?.toString(),
                  snapshotPrice: _parseIntValue(json['snapshotPrice']),
                  quantity: _parseIntValue(json['quantity']),
                  lineTotal: _parseIntValue(json['lineTotal']),
                ),
              ]
            : null;

    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      status: json['status'],
      deliveryDatetime: json['deliveryDatetime'] != null
          ? DateTime.parse(json['deliveryDatetime'])
          : null,
      paymentDatetime: json['paymentDatetime'] != null
          ? DateTime.parse(json['paymentDatetime'])
          : null,
      discountValue: _parseIntValue(json['discountValue']),
      subTotal: _parseIntValue(json['subTotal']),
      total: _parseIntValue(json['total']),
      note: json['note']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      items: parsedItems,
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
      'paymentDatetime': paymentDatetime?.toIso8601String(),
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
      paymentDatetime: entity.paymentDatetime,
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
      paymentDatetime: paymentDatetime,
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
        'paymentDatetime: $paymentDatetime, '
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
