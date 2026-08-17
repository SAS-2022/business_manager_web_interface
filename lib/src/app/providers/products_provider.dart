import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Use the shared ProductsParams
final productsStreamProvider =
    StreamProvider.family<List<Product>, ProductsParams>((ref, params) {
  final productService = ref.watch(productServiceProvider);
  return productService.getAllUserProducts(params.uid,
      category: params.category);
});

final productsProvider =
    FutureProvider.family<List<Product>, ProductsParams>((ref, params) async {
  final productService = ref.watch(productServiceProvider);
  final products = await productService
      .getAllUserProducts(params.uid, category: params.category)
      .first;
  return products;
});

// Provider to refresh products
final productsRefreshProvider = Provider((ref) {
  return (String uid, {String? category}) {
    ref.invalidate(productsProvider(ProductsParams(uid, category)));
  };
});

class ProductsParams {
  final String uid;
  final String? category;

  ProductsParams(this.uid, this.category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsParams &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          category == other.category;

  @override
  int get hashCode => uid.hashCode ^ category.hashCode;
}
