import '../../core/common/result.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Result<List<AddressEntity>>> getAllAddress();
  Future<Result<AddressEntity?>> getAddress(String code);
  Future<Result<String>> createAddress(AddressEntity address);
  Future<Result<void>> updateAddress(AddressEntity address);
  Future<Result<void>> deleteAddress(String code);
}