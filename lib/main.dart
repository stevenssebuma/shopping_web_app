import 'package:flutter/material.dart';
import './assets/models/product_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// -----------------------------------------------------------------------------
// MAIN FUNCTION & APP SETUP (This is where the app runs)
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Web App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// HOMEPAGE - FETCHING PRODUCTS FROM REALTIME DATABASE
// -----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _cart = []; // Local cart for session, for simplicity

  // Realtime Database reference for products
  final DatabaseReference _productsRef = FirebaseDatabase.instance.ref(
    'products',
  );

  List<Product> _realtimeProducts = []; // List to hold products from RTDB
  bool _isLoading = true; // State to show loading indicator
  String? _errorMessage; // State to show error message

  @override
  void initState() {
    super.initState();
    _listenForProducts(); // Start listening for product changes
  }

  // Method to set up a real-time listener for products
  void _listenForProducts() {
    _productsRef.onValue.listen(
      (event) {
        final data = event.snapshot.value; // Get the raw data from the snapshot
        final List<Product> loadedProducts = [];

        if (event.snapshot.exists && data != null && data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              // Create Product object from the map data
              loadedProducts.add(Product.fromMap(key, value));
            }
          });
        }
        setState(() {
          _realtimeProducts = loadedProducts;
          _isLoading = false;
          _errorMessage = null; // Clear any previous errors
        });
        print(
          'Products updated from Realtime Database: ${_realtimeProducts.length} items',
        );
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Failed to load products: ${error.toString()}';
          _isLoading = false;
        });
        print('Realtime Database Error: $error');
      },
    );
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
      // Optional: Show a snackbar confirming item added
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.name} added to cart!')));
    });
  }

  void _showCartDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cartItems: _cart)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Show loading indicator
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!)) // Show error message
                : _realtimeProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products available. Add some to your Realtime Database!',
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount:
                          _realtimeProducts.length, // Use products from RTDB
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product:
                              _realtimeProducts[index], // Pass products from RTDB
                          onAddToCart: () =>
                              _addToCart(_realtimeProducts[index]),
                        );
                      },
                    ),
                  ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.shopping_bag, size: 28),
          const SizedBox(width: 8),
          const Text(
            'Shopping Web App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      backgroundColor: Colors.indigo,
      actions: [
        IconButton(
          tooltip: 'Favorites',
          onPressed: () {
            // Implement favorites functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Favorites functionality not implemented yet.'),
              ),
            );
          },
          icon: const Icon(Icons.favorite_border),
        ),
        Stack(
          children: [
            IconButton(
              tooltip: 'Cart',
              icon: const Icon(Icons.shopping_cart),
              onPressed: _showCartDialog,
            ),
            if (_cart.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    _cart.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.indigo.shade50,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(' 2025 Shopping Web App', style: TextStyle(color: Colors.grey)),
          Text('Terms | Privacy', style: TextStyle(color: Colors.blueAccent)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT CARD (uses the Product model to generate cards for each product)
// -----------------------------------------------------------------------------
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 50,
                ), // Fallback for missing images
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARTPAGE - PLACING ORDERS TO REALTIME DATABASE
// -----------------------------------------------------------------------------
class CartPage extends StatefulWidget {
  final List<Product> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Realtime Database reference for orders
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');

  void _removeFromCart(Product product) {
    setState(() {
      widget.cartItems.remove(product);
    });
  }

  double getTotal() {
    return widget.cartItems.fold(0, (sum, item) => sum + item.price);
  }

  Future<void> _makeOrder() async {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty. Add items before ordering.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text(
          'Proceed to order ${widget.cartItems.length} item(s) for \$${getTotal().toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close confirmation dialog

              // -------------------------------------------------------
              // Firebase Realtime Database: Push Order
              // -------------------------------------------------------
              try {
                // Create a new unique key for the order
                final newOrderRef = _ordersRef.push();

                // Prepare order details
                final orderDetails = {
                  'userId':
                      'guest_user_123', // Replace with actual user ID if using Firebase Auth
                  'timestamp':
                      ServerValue.timestamp, // Use Firebase server timestamp
                  'totalPrice': getTotal(),
                  'items': widget.cartItems
                      .map(
                        (product) => {
                          'productId': product.id,
                          'name': product.name,
                          'price': product.price,
                        },
                      )
                      .toList(), // Convert list of Products to list of Maps
                };

                // Push the order to the database
                await newOrderRef.set(orderDetails);

                setState(() {
                  widget.cartItems.clear(); // Clear the local cart
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );
                print(
                  'Order placed to Realtime Database with ID: ${newOrderRef.key}',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to place order: ${e.toString()}'),
                  ),
                );
                print('Error placing order to Realtime Database: $e');
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_bag, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Shopping Web App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            tooltip: 'Back to Home',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartItems.isEmpty
                ? const Center(
                    child: Text(
                      "Your cart is empty, you can go back for more products.",
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        leading: Image.asset(
                          item.imagePath,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                        title: Text(item.name),
                        subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Remove item',
                          onPressed: () => _removeFromCart(item),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(height: 20),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            alignment: Alignment.centerRight,
            child: Text(
              "Total: \$${getTotal().toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _makeOrder,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Make Order'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  ' 2025 Shopping Web App',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Terms | Privacy',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
