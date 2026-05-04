import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'params/no_param.dart';


class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}
