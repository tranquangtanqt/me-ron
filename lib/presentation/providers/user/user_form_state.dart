class UserFormState {
  final String? name;
  final String? address;
  final String? phone;
  final String? note;
  final bool isLoaded;

  const UserFormState({
    this.name,
    this.address,
    this.phone,
    this.note,
    this.isLoaded = false,
  });

  UserFormState copyWith({
    String? name,
    String? address,
    String? phone,
    String? note,
    bool? isLoaded,
  }) {
    return UserFormState(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
