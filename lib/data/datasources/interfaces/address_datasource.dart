import '../../../core/common/result.dart';
import '../../models/address_model.dart';

abstract class AddressDatasource {
  Future<Result<List<AddressModel>>> getAllAddress();

  Future<Result<AddressModel?>> getAddress(String code);

  Future<Result<String>> createAddress(AddressModel add);

  Future<Result<void>> updateAddress(AddressModel address);

  Future<Result<void>> deleteAddress(String code);
}
