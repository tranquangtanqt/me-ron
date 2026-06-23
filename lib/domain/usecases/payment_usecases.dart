import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/payment_model.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

// class GetAllPaymentUsecase extends Usecase<Result, PaymentParams> {
//   GetAllPaymentUsecase(this._paymentRepository);
//
//   final PaymentRepository _paymentRepository;
//
//   @override
//   Future<Result<List<PaymentModel>>> call(PaymentParams params) async => _paymentRepository.getAllPayments(params);
// }

class GetPaymentUsecase extends Usecase<Result, int> {
  GetPaymentUsecase(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  @override
  Future<Result<List<PaymentModel>>> call(int params) async => _paymentRepository.getPayment(params);
}

class CreatePaymentUsecase extends Usecase<Result, PaymentEntity> {
  CreatePaymentUsecase(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  @override
  Future<Result<int>> call(PaymentEntity params) async => _paymentRepository.createPayment(params);
}

class UpdatePaymentUsecase extends Usecase<Result<void>, PaymentEntity> {
  UpdatePaymentUsecase(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  @override
  Future<Result<void>> call(PaymentEntity params) async => _paymentRepository.updatePayment(params);
}

class DeletePaymentUsecase extends Usecase<Result<void>, int> {
  DeletePaymentUsecase(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  @override
  Future<Result<void>> call(int params) async => _paymentRepository.deletePayment(params);
}

