import 'package:me_ron/domain/usecases/params/base_params.dart';

import '../../core/common/result.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getAllProducts(BaseParams params);

  Future<Result<ProductEntity?>> getProduct(int productId);

  Future<Result<int>> createProduct(ProductEntity product);

  Future<Result<void>> updateProduct(ProductEntity product);

  Future<Result<void>> deleteProduct(int productId);
}
