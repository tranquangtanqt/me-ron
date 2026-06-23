import '../../core/common/result.dart';
import '../../data/models/payment_model.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {

  Future<Result<List<PaymentModel>>> getPayment(int paymentId);

  Future<Result<int>> createPayment(PaymentEntity payment);

  Future<Result<void>> updatePayment(PaymentEntity payment);

  Future<Result<void>> deletePayment(int paymentId);
}
