import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';
import 'params/base_params.dart';

class GetAllAddressUsecase extends Usecase<Result, BaseParams> {
  GetAllAddressUsecase(this._addressRepository);

  final AddressRepository _addressRepository;

  @override
  Future<Result<List<AddressEntity>>> call(BaseParams params) async => _addressRepository.getAllAddress();
}

class GetAddressUsecase extends Usecase<Result, String> {
  GetAddressUsecase(this._addressRepository);

  final AddressRepository _addressRepository;

  @override
  Future<Result<AddressEntity?>> call(String params) async => _addressRepository.getAddress(params);
}

class CreateAddressUsecase extends Usecase<Result, AddressEntity> {
  CreateAddressUsecase(this._addressRepository);

  final AddressRepository _addressRepository;

  @override
  Future<Result<String>> call(AddressEntity params) async {
    final currentAddress = await _addressRepository.getAddress(params.code);

    if (currentAddress.data != null) {
      return Result.success(data: currentAddress.data!.code);
    }

    return await _addressRepository.createAddress(params);
  }
}

class UpdateAddressUsecase extends Usecase<Result<void>, AddressEntity> {
  UpdateAddressUsecase(this._addressRepository);

  final AddressRepository _addressRepository;

  @override
  Future<Result<void>> call(AddressEntity params) async => _addressRepository.updateAddress(params);
}

class DeleteAddressUsecase extends Usecase<Result<void>, String> {
  DeleteAddressUsecase(this._addressRepository);

  final AddressRepository _addressRepository;

  @override
  Future<Result<void>> call(String params) async => _addressRepository.deleteAddress(params);
}
