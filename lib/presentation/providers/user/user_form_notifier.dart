import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../base/base_form_notifier.dart';
import 'user_form_state.dart';
import 'user_notifier.dart';

final userFormNotifierProvider = NotifierProvider.autoDispose<UserFormNotifier, UserFormState>(
  UserFormNotifier.new,
);

class UserFormNotifier extends BaseFormNotifier<UserFormState> {
  @override
  UserFormState build() {
    return const UserFormState();
  }

  Future<void> initUserForm(int? id) async {
    if (id == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final userRepository = ref.read(userRepositoryProvider);
    var res = await GetUserUsecase(userRepository).call(id);

    if (res.isSuccess) {
      var user = res.data;

      state = state.copyWith(
        name: user?.name,
        address: user?.address,
        phone: user?.phone,
        note: user?.note,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createUser() async {
    return performCreate(
      execute: () async {
        final userRepository = ref.read(userRepositoryProvider);
        final user = UserEntity(
          name: state.name ?? '',
          address: state.address ?? '',
          phone: state.phone ?? '',
          note: state.note ?? '',
        );
        return await CreateUserUsecase(userRepository).call(user);
      },
      onSuccess: () => ref.read(userNotifierProvider.notifier).getAllUser(),
    );
  }

  Future<Result<void>> updatedUser(int id) async {
    return performUpdate(
      execute: () async {
        final userRepository = ref.read(userRepositoryProvider);
        final user = UserEntity(
          id: id,
          name: state.name!,
          address: state.address,
          phone: state.phone,
          note: state.note,
        );
        return await UpdateUserUsecase(userRepository).call(user);
      },
      onSuccess: () => ref.read(userNotifierProvider.notifier).getAllUser(),
    );
  }

  Future<Result<void>> deleteUser(int id) async {
    return performDelete(
      execute: () async {
        final userRepository = ref.read(userRepositoryProvider);
        return await DeleteUserUsecase(userRepository).call(id);
      },
      onSuccess: () => ref.read(userNotifierProvider.notifier).getAllUser(),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(userNotifierProvider.notifier).getAllUser();
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedAddress(String value) {
    state = state.copyWith(address: value);
  }

  void onChangedPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void onChangedNote(String value) {
    state = state.copyWith(note: value);
  }
}
