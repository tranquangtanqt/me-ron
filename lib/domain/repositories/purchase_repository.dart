import '../../core/common/result.dart';
import '../../data/models/purchase_model.dart';
import '../entities/purchase_entity.dart';
import '../usecases/params/purchase_params.dart';

abstract class PurchaseRepository {
  Future<Result<List<PurchaseModel>>> getAllPurchases(PurchaseParams params);

  Future<Result<PurchaseModel?>> getPurchase(int purchaseId);

  Future<Result<int>> createPurchase(PurchaseEntity purchase);

  Future<Result<int>> createPurchaseWithItems(PurchaseEntity purchase, List<dynamic> items);

  Future<Result<void>> updatePurchase(PurchaseEntity purchase);

  Future<Result<void>> updatePurchaseWithItems(PurchaseEntity purchase, List<dynamic> items);

  Future<Result<void>> deletePurchase(int purchaseId);
}
