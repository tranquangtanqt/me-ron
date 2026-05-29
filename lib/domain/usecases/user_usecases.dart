import 'package:flutter_pos/domain/usecases/params/base_params.dart';

import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUserUsecase extends Usecase<Result, BaseParams> {
  GetAllUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<List<UserEntity>>> call(BaseParams params) async => _userRepository.getAllUser();
}

class GetUserUsecase extends Usecase<Result, int> {
  GetUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity?>> call(int params) async => _userRepository.getUser(params);
}

class CreateUserUsecase extends Usecase<Result, UserEntity> {
  CreateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<int>> call(UserEntity params) async {
    if (params.id != null) {
      final currentUser = await _userRepository.getUser(params.id!);

      if (currentUser.data != null) {
        return Result.success(data: currentUser.data!.id!);
      }
    }

    return await _userRepository.createUser(params);
  }
}

class UpdateUserUsecase extends Usecase<Result<void>, UserEntity> {
  UpdateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(UserEntity params) async => _userRepository.updateUser(params);
}

class DeleteUserUsecase extends Usecase<Result<void>, int> {
  DeleteUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(int params) async => _userRepository.deleteUser(params);
}
