import 'package:flutter/material.dart';
import './assets/models/product_model.dart';
import './assets/data/dummy_products.dart';

void main() {
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _cart = [];

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: dummyProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: dummyProducts[index],
                    onAddToCart: () => _addToCart(dummyProducts[index]),
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
          onPressed: () {},
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
              child: Image.asset(product.imagePath, fit: BoxFit.cover),
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

class CartPage extends StatefulWidget {
  final List<Product> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _removeFromCart(Product product) {
    setState(() {
      widget.cartItems.remove(product);
    });
  }

  double getTotal() {
    return widget.cartItems.fold(0, (sum, item) => sum + item.price);
  }

  void _makeOrder() {
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
            onPressed: () {
              setState(() {
                widget.cartItems.clear(); // Clear the cart
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
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
                ? const Center(child: Text("Your cart is empty."))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        leading: Image.asset(item.imagePath, width: 50),
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
