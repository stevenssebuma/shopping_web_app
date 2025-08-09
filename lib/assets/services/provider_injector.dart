import 'package:your_project_name/repositories/product_repository.dart';
import 'package:your_project_name/repositories/dummy_product_repository.dart';

class ProviderInjector {
  // Swap to FirestoreProductRepository() when you enable Firestore
  static final ProductRepository productRepository = DummyProductRepository();
}
