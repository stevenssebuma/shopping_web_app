import 'package:your_project_name/models/product_model.dart';
import 'package:your_project_name/data/dummy_products.dart';

class DummyProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return dummyProducts.map((p) => Product.fromDummy(p)).toList();
  }
}
