import '../../../domain/entities/address_entity.dart';

class AddressState {
  final List<AddressEntity>? allAddress;
  final bool isLoadingMore;
  final String? error;

  const AddressState({
    this.allAddress,
    this.isLoadingMore = false,
    this.error
  });

  AddressState copyWith({
    List<AddressEntity>? allAddress,
    bool? isLoadingMore,
    String? error
  }) {
    return AddressState(
      allAddress: allAddress ?? this.allAddress,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
