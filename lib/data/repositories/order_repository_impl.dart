import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/params/base_params.dart';
import '../../domain/usecases/params/order_params.dart';
import '../../domain/usecases/params/report_customer_params.dart';
import '../../domain/usecases/params/report_order_params.dart';
import '../../domain/usecases/params/report_product_params.dart';
import '../datasources/local/order_local_datasource_impl.dart';
import '../datasources/local/order_item_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/customer_summary_model.dart';
import '../models/order_customer_summary_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/order_status_summary_model.dart';
import '../models/product_summary_model.dart';
import '../models/queued_action_model.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderLocalDatasourceImpl orderLocalDatasource;
  final OrderItemLocalDatasourceImpl orderItemLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  OrderRepositoryImpl({
    required this.orderLocalDatasource,
    required this.orderItemLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params) async {
    try {
      final local = await orderLocalDatasource.getAllOrders(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      // return Result.success(data: list.map((e) => e.toEntity()).toList());
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> getOrdersCount(OrderParams params) async {
    try {
      final local = await orderLocalDatasource.getOrdersCount(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getAllOrderReportProduct(ReportProductParams params) async {
    try {
      final local = await orderLocalDatasource.getAllOrderReportProduct(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      // return Result.success(data: list.map((e) => e.toEntity()).toList());
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> getOrdersCountReportProduct(ReportProductParams params) async {
    try {
      final local = await orderLocalDatasource.getOrdersCountReportProduct(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductSummaryModel>>> getProductSummaryReportProduct(ReportProductParams params) async {
    try {
      final local = await orderLocalDatasource.getProductSummaryReportProduct(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? []);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getAllOrderReportOrder(ReportOrderParams params) async {
    try {
      final local = await orderLocalDatasource.getAllOrderReportOrder(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      // return Result.success(data: list.map((e) => e.toEntity()).toList());
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> getOrdersCountReportOrder(ReportOrderParams params) async {
    try {
      final local = await orderLocalDatasource.getOrdersCountReportOrder(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderStatusSummaryModel>>> getOrderStatusSummary(ReportOrderParams params) async {
    try {
      final local = await orderLocalDatasource.getOrderStatusSummary(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? []);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductSummaryModel>>> getOrderProductSummary(ReportOrderParams params) async {
    try {
      final local = await orderLocalDatasource.getOrderProductSummary(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? []);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderCustomerSummaryModel>>> getCustomerSummaryReportOrder(ReportOrderParams params) async {
    try {
      final local = await orderLocalDatasource.getCustomerSummaryReportOrder(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? []);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<CustomerSummaryModel>>> getTopCustomers(ReportCustomerParams params) async {
    try {
      final local = await orderLocalDatasource.getTopCustomers(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data ?? []);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrderWithItems(OrderEntity order, List<dynamic> items) async {
    try {
      final data = OrderModel.fromEntity(order);

      final itemsModels = items.map((dynamic it) => OrderItemModel.fromEntity(it as OrderItemEntity)).toList();

      final local = await orderLocalDatasource.createOrderWithItems(data, itemsModels);
      if (local.isFailure) return Result.failure(error: local.error!);

      final createdOrderId = local.data!;

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'createOrderWithItems',
          param: jsonEncode({
            'order': data.toJson(),
            'items': itemsModels.map((e) => e.toJson()).toList(),
          }),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: createdOrderId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getOrder(int orderId) async {
    try {
      final local = await orderLocalDatasource.getOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrder(OrderEntity order) async {
    try {
      final data = OrderModel.fromEntity(order);

      final local = await orderLocalDatasource.createOrder(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'createOrder',
          param: jsonEncode((data).toJson()),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteOrder(int orderId) async {
    try {
      final local = await orderLocalDatasource.deleteOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'deleteOrder',
          param: orderId.toString(),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateOrder(OrderEntity order) async {
    try {
      final local = await orderLocalDatasource.updateOrder(OrderModel.fromEntity(order));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'updateOrder',
          param: jsonEncode(OrderModel.fromEntity(order).toJson()),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateOrderWithItems(OrderEntity order, List<dynamic> items) async {
    try {
      final data = OrderModel.fromEntity(order);
      final itemsModels = items.map((dynamic it) => OrderItemModel.fromEntity(it as OrderItemEntity)).toList();

      final local = await orderLocalDatasource.updateOrderWithItems(data, itemsModels);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'updateOrderWithItems',
          param: jsonEncode({
            'order': data.toJson(),
            'items': itemsModels.map((e) => e.toJson()).toList(),
          }),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateStatusOrder(int orderId, int status) async {
    try {
      final local = await orderLocalDatasource.updateStatusOrder(orderId, status);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'updateStatusOrder',
          param: jsonEncode({
            'id': orderId,
            'status': status,
          }),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
