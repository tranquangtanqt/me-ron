import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/address_usecases.dart';
import 'address_state.dart';

final addressNotifierProvider = NotifierProvider<AddressNotifier, AddressState>(
  AddressNotifier.new,
);

class AddressNotifier extends Notifier<AddressState> {
  @override
  AddressState build() {
    return const AddressState();
  }

  void resetAddress() {
    state = const AddressState();
  }

  Future<void> getAllAddress({int? offset}) async {
    try {
      if (offset != null) {
        state = state.copyWith(isLoadingMore: true);
      }

      var params = BaseParams(
        offset: offset,
      );

      final addressRepository = ref.read(addressRepositoryProvider);
      var res = await GetAllAddressUsecase(addressRepository).call(params);

      if (res.isSuccess) {
        if (offset == null) {
          state = state.copyWith(
              allAddress: res.data ?? [],
              isLoadingMore: false,
              error: null,
          );
        } else {
          final current = state.allAddress ?? [];
          state = state.copyWith(
            allAddress: [...current, ...res.data ?? []],
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
