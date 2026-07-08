import '../../core/common/result.dart';
import '../../data/models/purchase_item_model.dart';
import '../entities/purchase_item_entity.dart';
import '../usecases/params/base_params.dart';

abstract class PurchaseItemRepository {
  Future<Result<List<PurchaseItemModel>>> getAllPurchaseItems(BaseParams params);

  Future<Result<List<PurchaseItemModel>>> getPurchaseItemsByPurchaseId(int purchaseId);

  Future<Result<PurchaseItemEntity?>> getPurchaseItem(int purchaseItemId);

  Future<Result<int>> createPurchaseItem(PurchaseItemEntity purchaseItem);

  Future<Result<void>> updatePurchaseItem(PurchaseItemEntity purchaseItem);

  Future<Result<void>> deletePurchaseItem(int purchaseItemId);
}
