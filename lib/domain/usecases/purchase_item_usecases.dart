import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/purchase_item_model.dart';
import '../entities/purchase_item_entity.dart';
import '../repositories/purchase_item_repository.dart';
import 'params/base_params.dart';

class GetAllPurchaseItemUsecase extends Usecase<Result, BaseParams> {
  GetAllPurchaseItemUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<List<PurchaseItemModel>>> call(BaseParams params) async =>
      _purchaseItemRepository.getAllPurchaseItems(params);
}

class GetPurchaseItemsByPurchaseIdUsecase extends Usecase<Result, int> {
  GetPurchaseItemsByPurchaseIdUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<List<PurchaseItemModel>>> call(int params) async =>
      _purchaseItemRepository.getPurchaseItemsByPurchaseId(params);
}

class GetPurchaseItemUsecase extends Usecase<Result, int> {
  GetPurchaseItemUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<PurchaseItemEntity?>> call(int params) async => _purchaseItemRepository.getPurchaseItem(params);
}

class CreatePurchaseItemUsecase extends Usecase<Result, PurchaseItemEntity> {
  CreatePurchaseItemUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<int>> call(PurchaseItemEntity params) async => _purchaseItemRepository.createPurchaseItem(params);
}

class UpdatePurchaseItemUsecase extends Usecase<Result<void>, PurchaseItemEntity> {
  UpdatePurchaseItemUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<void>> call(PurchaseItemEntity params) async => _purchaseItemRepository.updatePurchaseItem(params);
}

class DeletePurchaseItemUsecase extends Usecase<Result<void>, int> {
  DeletePurchaseItemUsecase(this._purchaseItemRepository);

  final PurchaseItemRepository _purchaseItemRepository;

  @override
  Future<Result<void>> call(int params) async => _purchaseItemRepository.deletePurchaseItem(params);
}
