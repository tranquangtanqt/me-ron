import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/usecases/address_usecases.dart';
import '../base/base_form_notifier.dart';
import 'address_form_state.dart';
import 'address_notifier.dart';

final addressFormNotifierProvider = NotifierProvider.autoDispose<AddressFormNotifier, AddressFormState>(
  AddressFormNotifier.new,
);

class AddressFormNotifier extends BaseFormNotifier<AddressFormState> {
  @override
  AddressFormState build() {
    return const AddressFormState();
  }

  Future<void> initAddressForm(String? addressCode) async {
    if (addressCode == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final addressRepository = ref.read(addressRepositoryProvider);
    var res = await GetAddressUsecase(addressRepository).call(addressCode);

    if (res.isSuccess) {
      var address = res.data;

      state = state.copyWith(
        code: address?.code,
        name: address?.name,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<String>> createAddress() async {
    return performCreate(
      execute: () async {
        final addressRepository = ref.read(addressRepositoryProvider);
        final address = AddressEntity(
          code: state.code ?? '',
          name: state.name ?? '',
        );
        return await CreateAddressUsecase(addressRepository).call(address);
      },
      onSuccess: () => ref.read(addressNotifierProvider.notifier).getAllAddress(),
    );
  }

  Future<Result<void>> updatedAddress(String code) async {
    return performUpdate(
      execute: () async {
        final addressRepository = ref.read(addressRepositoryProvider);
        final address = AddressEntity(
          code: code,
          name: state.name!,
        );
        return await UpdateAddressUsecase(addressRepository).call(address);
      },
      onSuccess: () => ref.read(addressNotifierProvider.notifier).getAllAddress(),
    );
  }

  Future<Result<void>> deleteAddress(String code) async {
    return performDelete(
      execute: () async {
        final addressRepository = ref.read(addressRepositoryProvider);
        return await DeleteAddressUsecase(addressRepository).call(code);
      },
      onSuccess: () => ref.read(addressNotifierProvider.notifier).getAllAddress(),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(addressNotifierProvider.notifier).getAllAddress();
  }

  void onChangedCode(String value) {
    state = state.copyWith(code: value);
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }
}
