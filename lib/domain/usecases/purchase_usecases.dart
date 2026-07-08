import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/purchase_model.dart';
import '../entities/purchase_entity.dart';
import '../repositories/purchase_repository.dart';
import 'params/purchase_params.dart';

class GetAllPurchaseUsecase extends Usecase<Result, PurchaseParams> {
  GetAllPurchaseUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<List<PurchaseModel>>> call(PurchaseParams params) async => _purchaseRepository.getAllPurchases(params);
}

class GetPurchaseUsecase extends Usecase<Result, int> {
  GetPurchaseUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<PurchaseModel?>> call(int params) async => _purchaseRepository.getPurchase(params);
}

class CreatePurchaseUsecase extends Usecase<Result, PurchaseEntity> {
  CreatePurchaseUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<int>> call(PurchaseEntity params) async => _purchaseRepository.createPurchase(params);
}

class CreatePurchaseWithItemsUsecase extends Usecase<Result, Map<String, dynamic>> {
  CreatePurchaseWithItemsUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<int>> call(Map<String, dynamic> params) async {
    final purchase = params['purchase'] as PurchaseEntity;
    final items = params['items'] as List;

    return _purchaseRepository.createPurchaseWithItems(purchase, items);
  }
}

class UpdatePurchaseUsecase extends Usecase<Result<void>, PurchaseEntity> {
  UpdatePurchaseUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<void>> call(PurchaseEntity params) async => _purchaseRepository.updatePurchase(params);
}

class UpdatePurchaseWithItemsUsecase extends Usecase<Result<void>, Map<String, dynamic>> {
  UpdatePurchaseWithItemsUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<void>> call(Map<String, dynamic> params) async {
    final purchase = params['purchase'] as PurchaseEntity;
    final items = params['items'] as List;

    return _purchaseRepository.updatePurchaseWithItems(purchase, items);
  }
}

class DeletePurchaseUsecase extends Usecase<Result<void>, int> {
  DeletePurchaseUsecase(this._purchaseRepository);

  final PurchaseRepository _purchaseRepository;

  @override
  Future<Result<void>> call(int params) async => _purchaseRepository.deletePurchase(params);
}
