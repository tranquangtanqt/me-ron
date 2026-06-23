import '../../../core/common/result.dart';
import '../../models/payment_model.dart';

abstract class PaymentDatasource {
  Future<Result<int>> createPayment(PaymentModel payment);

  Future<Result<void>> updatePayment(PaymentModel payment);

  Future<Result<void>> deletePayment(int id);

  Future<Result<List<PaymentModel>>> getPayment(int id);
}