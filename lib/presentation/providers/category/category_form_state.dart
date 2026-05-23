class CategoryFormState {
  final String? name;
  final String? description;
  final bool isLoaded;

  const CategoryFormState({
    this.name,
    this.description,
    this.isLoaded = false,
  });

  CategoryFormState copyWith({
    String? name,
    String? description,
    bool? isLoaded,
  }) {
    return CategoryFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
