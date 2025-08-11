class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  // Constructor to create a Product from a Map (useful when reading from Firebase)
  factory Product.fromMap(String id, Map<dynamic, dynamic> map) {
    return Product(
      id: id, // Use the key from Firebase as the product ID
      name: map['name'] as String? ?? 'Unknown Product',
      description: map['description'] as String? ?? 'No description available',
      price:
          (map['price'] as num?)?.toDouble() ??
          0.0, // Handle int/double from Firebase
      imagePath:
          map['imagePath'] as String? ??
          'assets/images/default.jpg', // Default image
    );
  }

  // Method to convert a Product to a Map (useful when writing to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
    };
  }
}
