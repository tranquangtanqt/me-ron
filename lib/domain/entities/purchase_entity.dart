import 'package:equatable/equatable.dart';

class PurchaseEntity extends Equatable {
  final int? id;
  final String date;
  final int total;
  final String? createdAt;
  final String? updatedAt;

  const PurchaseEntity({
    this.id,
    required this.date,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  PurchaseEntity copyWith({
    final int? id,
    final String? date,
    final int? total,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return PurchaseEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    total,
    createdAt,
    updatedAt,
  ];
}
