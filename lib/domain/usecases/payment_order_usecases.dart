import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/payment_order_model.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_order_entity.dart';
import '../repositories/payment_order_repository.dart';
import '../repositories/payment_repository.dart';

// class GetAllPaymentOrderUsecase extends Usecase<Result, PaymentOrderParams> {
//   GetAllPaymentOrderUsecase(this._paymentRepository);
//
//   final PaymentOrderRepository _paymentRepository;
//
//   @override
//   Future<Result<List<PaymentOrderModel>>> call(PaymentOrderParams params) async => _paymentRepository.getAllPaymentOrders(params);
// }

class GetPaymentOrderUsecase extends Usecase<Result, int> {
  GetPaymentOrderUsecase(this._paymentOrderRepository);

  final PaymentOrderRepository _paymentOrderRepository;

  @override
  Future<Result<List<PaymentOrderModel>>> call(int params) async => _paymentOrderRepository.getPaymentOrder(params);
}

class CreatePaymentOrderUsecase extends Usecase<Result, PaymentOrderEntity> {
  CreatePaymentOrderUsecase(this._paymentOrderRepository);

  final PaymentOrderRepository _paymentOrderRepository;

  @override
  Future<Result<int>> call(PaymentOrderEntity params) async => _paymentOrderRepository.createPaymentOrder(params);
}

class UpdatePaymentOrderUsecase extends Usecase<Result<void>, PaymentOrderEntity> {
  UpdatePaymentOrderUsecase(this._paymentOrderRepository);

  final PaymentOrderRepository _paymentOrderRepository;

  @override
  Future<Result<void>> call(PaymentOrderEntity params) async => _paymentOrderRepository.updatePaymentOrder(params);
}

class DeletePaymentOrderUsecase extends Usecase<Result<void>, int> {
  DeletePaymentOrderUsecase(this._paymentOrderRepository);

  final PaymentOrderRepository _paymentOrderRepository;

  @override
  Future<Result<void>> call(int params) async => _paymentOrderRepository.deletePaymentOrder(params);
}

