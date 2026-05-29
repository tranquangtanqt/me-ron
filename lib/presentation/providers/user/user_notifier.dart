import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/user_usecases.dart';
import 'user_state.dart';

final userNotifierProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return const UserState();
  }

  void resetUser() {
    state = const UserState();
  }

  Future<void> getAllUser({int? offset}) async {
    try {
      if (offset != null) {
        state = state.copyWith(isLoadingMore: true);
      }

      var params = BaseParams(
        offset: offset,
      );

      final userRepository = ref.read(userRepositoryProvider);
      var res = await GetAllUserUsecase(userRepository).call(params);

      if (res.isSuccess) {
        if (offset == null) {
          state = state.copyWith(
              allUser: res.data ?? [],
              isLoadingMore: false,
              error: null,
          );
        } else {
          final current = state.allUser ?? [];
          state = state.copyWith(
            allUser: [...current, ...res.data ?? []],
            isLoadingMore: false,
          );
        }
      } else {
        state = state.copyWith(
            isLoadingMore: false,
            error: res.error?.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}
