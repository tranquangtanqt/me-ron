import '../../../core/common/result.dart';
import '../../models/payment_order_model.dart';

abstract class PaymentOrderDatasource {
  Future<Result<int>> createPaymentOrder(PaymentOrderModel paymentOrder);

  Future<Result<void>> updatePaymentOrder(PaymentOrderModel paymentOrder);

  Future<Result<void>> deletePaymentOrder(int id);

  Future<Result<List<PaymentOrderModel>>> getPaymentOrder(int id);
}