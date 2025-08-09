class Product {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });

  /// Creates a Product from dummy/local data
  factory Product.fromDummy(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '',
    );
  }

  /// Creates a Product from Firestore data
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '',
    );
  }
}
