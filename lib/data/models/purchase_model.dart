import '../../domain/entities/purchase_entity.dart';
import 'purchase_item_model.dart';

int _parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class PurchaseModel {
  int? id;
  String date;
  int total;
  String? createdAt;
  String? updatedAt;
  List<PurchaseItemModel>? items;
  int? purchaseItemId;
  String? itemName;
  int? itemPrice;

  PurchaseModel({
    this.id,
    required this.date,
    required this.total,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.purchaseItemId,
    this.itemName,
    this.itemPrice,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final dynamic itemsJson = json['items'];
    final bool hasFlatItemFields = json['purchaseItemId'] != null || json['itemName'] != null;

    final List<PurchaseItemModel>? parsedItems = itemsJson is List
        ? itemsJson.whereType<Map>().map((item) => PurchaseItemModel.fromJson(Map<String, dynamic>.from(item))).toList()
        : hasFlatItemFields
        ? [
            PurchaseItemModel(
              id: json['purchaseItemId'],
              purchaseId: json['id'],
              name: json['itemName']?.toString(),
              price: _parseIntValue(json['itemPrice']),
            ),
          ]
        : null;

    return PurchaseModel(
      id: json['id'],
      date: json['date'] ?? '',
      total: json['total'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      items: parsedItems,
      purchaseItemId: json['purchaseItemId'],
      itemName: json['itemName']?.toString(),
      itemPrice: json['itemPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'total': total,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PurchaseModel.fromEntity(PurchaseEntity entity) {
    return PurchaseModel(
      id: entity.id,
      date: entity.date,
      total: entity.total,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  PurchaseEntity toEntity() {
    return PurchaseEntity(
      id: id,
      date: date,
      total: total,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
