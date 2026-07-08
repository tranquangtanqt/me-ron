import '../../../core/common/result.dart';
import '../../../domain/usecases/params/purchase_params.dart';
import '../../models/purchase_item_model.dart';
import '../../models/purchase_model.dart';

abstract class PurchaseDatasource {
  Future<Result<int>> createPurchase(PurchaseModel purchase);

  Future<Result<int>> createPurchaseWithItems(PurchaseModel purchase, List<PurchaseItemModel> items);

  Future<Result<void>> updatePurchase(PurchaseModel purchase);

  Future<Result<void>> updatePurchaseWithItems(PurchaseModel purchase, List<PurchaseItemModel> items);

  Future<Result<void>> deletePurchase(int id);

  Future<Result<PurchaseModel?>> getPurchase(int id);

  Future<Result<List<PurchaseModel>>> getAllPurchases(PurchaseParams params);
}
