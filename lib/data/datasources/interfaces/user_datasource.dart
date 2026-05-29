import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class UserDatasource {
  Future<Result<List<UserModel>>> getAllUser();

  Future<Result<UserModel?>> getUser(int id);

  Future<Result<int>> createUser(UserModel user);

  Future<Result<void>> updateUser(UserModel user);

  Future<Result<void>> deleteUser(int id);


}
