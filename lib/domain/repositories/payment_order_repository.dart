import '../../core/common/result.dart';
import '../../data/models/payment_order_model.dart';
import '../entities/payment_order_entity.dart';

abstract class PaymentOrderRepository {

  Future<Result<List<PaymentOrderModel>>> getPaymentOrder(int paymentOrderId);

  Future<Result<int>> createPaymentOrder(PaymentOrderEntity paymentOrder);

  Future<Result<void>> updatePaymentOrder(PaymentOrderEntity paymentOrder);

  Future<Result<void>> deletePaymentOrder(int paymentOrderId);
}
