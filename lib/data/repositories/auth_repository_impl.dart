import '../../../../core/common/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  @override
  Future<Result<void>> signOut() async {
    try {
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
