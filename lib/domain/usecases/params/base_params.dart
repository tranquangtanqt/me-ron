import 'package:equatable/equatable.dart';

class BaseParams<T> extends Equatable {
  final T? param;
  final String orderBy;
  final String sortBy;
  final int limit;
  final int? offset;
  final String? contains;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? status;

  const BaseParams({
    this.param,
    this.orderBy = 'createdAt',
    this.sortBy = 'DESC',
    this.limit = 10,
    this.offset,
    this.contains,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object> get props => [];
}
