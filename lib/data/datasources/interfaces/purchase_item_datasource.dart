import '../../../core/common/result.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../models/purchase_item_model.dart';

abstract class PurchaseItemDatasource {
  Future<Result<int>> createPurchaseItem(PurchaseItemModel purchaseItem);

  Future<Result<void>> updatePurchaseItem(PurchaseItemModel purchaseItem);

  Future<Result<void>> deletePurchaseItem(int id);

  Future<Result<PurchaseItemModel?>> getPurchaseItem(int id);

  Future<Result<List<PurchaseItemModel>>> getAllPurchaseItems(BaseParams params);

  Future<Result<List<PurchaseItemModel>>> getPurchaseItemsByPurchaseId(int purchaseId);
}
