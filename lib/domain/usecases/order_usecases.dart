import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status_summary_model.dart';
import '../../data/models/product_summary_model.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import '../../../domain/usecases/params/order_params.dart';
import '../../../domain/usecases/params/report_order_params.dart';
import '../../../domain/usecases/params/report_product_params.dart';

class GetAllOrderUsecase extends Usecase<Result, OrderParams> {
  GetAllOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(OrderParams params) async => _orderRepository.getAllOrders(params);
}

class GetOrdersCountUsecase extends Usecase<Result, OrderParams> {
  GetOrdersCountUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(OrderParams params) async => _orderRepository.getOrdersCount(params);
}

class GetAllOrderReportProductUsecase extends Usecase<Result, ReportProductParams> {
  GetAllOrderReportProductUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(ReportProductParams params) async =>
      _orderRepository.getAllOrderReportProduct(params);
}

class GetOrdersCountReportProductUsecase extends Usecase<Result, ReportProductParams> {
  GetOrdersCountReportProductUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(ReportProductParams params) async => _orderRepository.getOrdersCountReportProduct(params);
}

class GetProductSummaryReportProductUsecase extends Usecase<Result, ReportProductParams> {
  GetProductSummaryReportProductUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<ProductSummaryModel>>> call(ReportProductParams params) async =>
      _orderRepository.getProductSummaryReportProduct(params);
}

class GetAllOrderReportOrderUsecase extends Usecase<Result, ReportOrderParams> {
  GetAllOrderReportOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(ReportOrderParams params) async =>
      _orderRepository.getAllOrderReportOrder(params);
}

class GetOrdersCountReportOrderUsecase extends Usecase<Result, ReportOrderParams> {
  GetOrdersCountReportOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(ReportOrderParams params) async => _orderRepository.getOrdersCountReportOrder(params);
}

class GetOrderStatusSummaryUsecase extends Usecase<Result, ReportOrderParams> {
  GetOrderStatusSummaryUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderStatusSummaryModel>>> call(ReportOrderParams params) async =>
      _orderRepository.getOrderStatusSummary(params);
}

class GetOrderProductSummaryUsecase extends Usecase<Result, ReportOrderParams> {
  GetOrderProductSummaryUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<ProductSummaryModel>>> call(ReportOrderParams params) async =>
      _orderRepository.getOrderProductSummary(params);
}

class GetOrderUsecase extends Usecase<Result, int> {
  GetOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(int params) async => _orderRepository.getOrder(params);
}

class CreateOrderUsecase extends Usecase<Result, OrderEntity> {
  CreateOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(OrderEntity params) async => _orderRepository.createOrder(params);
}

class CreateOrderWithItemsUsecase extends Usecase<Result, Map<String, dynamic>> {
  CreateOrderWithItemsUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(Map<String, dynamic> params) async {
    final order = params['order'] as OrderEntity;
    final items = params['items'] as List;
    return _orderRepository.createOrderWithItems(order, items);
  }
}

class UpdateOrderWithItemsUsecase extends Usecase<Result<void>, Map<String, dynamic>> {
  UpdateOrderWithItemsUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(Map<String, dynamic> params) async {
    final order = params['order'] as OrderEntity;
    final items = params['items'] as List;
    return _orderRepository.updateOrderWithItems(order, items);
  }
}

class UpdateOrderUsecase extends Usecase<Result<void>, OrderEntity> {
  UpdateOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(OrderEntity params) async => _orderRepository.updateOrder(params);
}

class DeleteOrderUsecase extends Usecase<Result<void>, int> {
  DeleteOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(int params) async => _orderRepository.deleteOrder(params);
}

class UpdateStatusOrderUsecase extends Usecase<Result<void>, Map<String, int>> {
  UpdateStatusOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(Map<String, int> params) async {
    final orderId = params['orderId'];
    final status = params['status'];

    if (orderId == null || status == null) {
      return Result.failure(error: 'orderId and status are required');
    }

    return _orderRepository.updateStatusOrder(orderId, status);
  }
}
