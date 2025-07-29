import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartPage extends StatelessWidget {
  final List<Product> cartItems;

  const CartPage({super.key, required this.cartItems});

  double getTotal() {
    return cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, cartItems.length),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Your cart is empty."))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.asset(item.imagePath, width: 150),
                        title: Text(item.name),
                        subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
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
          _buildFooter(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int cartCount) {
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
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.home),
        ),
        Stack(
          children: [
            IconButton(
              tooltip: 'Cart',
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {},
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    cartCount.toString(),
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
