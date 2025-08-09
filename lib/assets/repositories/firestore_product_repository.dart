import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:your_project_name/models/product_model.dart';
import 'package:your_project_name/repositories/product_repository.dart';

/// Firestore implementation of the [ProductRepository].
class FirestoreProductRepository implements ProductRepository {
  // Reference to the 'products' collection in Firestore
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'products',
  );

  /// Fetches all products from Firestore, ordered by name.
  @override
  Future<List<Product>> fetchProducts() async {
    final querySnapshot = await _collection.orderBy('name').get();

    return querySnapshot.docs.map((doc) {
      return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
