class AddressFormState {
  final String? code;
  final String? name;
  final bool isLoaded;

  const AddressFormState({
    this.code,
    this.name,
    this.isLoaded = false,
  });

  AddressFormState copyWith({
    String? code,
    String? name,
    bool? isLoaded,
  }) {
    return AddressFormState(
      code: code ?? this.code,
      name: name ?? this.name,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
