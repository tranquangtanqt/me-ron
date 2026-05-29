import '../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<List<UserEntity>>> getAllUser();
  Future<Result<UserEntity?>> getUser(int id);
  Future<Result<int>> createUser(UserEntity user);
  Future<Result<void>> updateUser(UserEntity user);
  Future<Result<void>> deleteUser(int id);
}
