import 'dart:io';

class ProductFormState {
  final File? imageFile;
  final String? imageUrl;
  final int? categoryId;
  final String? name;
  final int? price;
  final String? description;
  final bool isLoaded;

  const ProductFormState({
    this.imageFile,
    this.imageUrl,
    this.categoryId,
    this.name,
    this.price,
    this.description,
    this.isLoaded = false,
  });

  ProductFormState copyWith({
    File? imageFile,
    String? imageUrl,
    int? categoryId,
    String? name,
    int? price,
    String? description,
    bool? isLoaded,
  }) {
    return ProductFormState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
