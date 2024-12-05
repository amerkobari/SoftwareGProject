import 'package:flutter/material.dart';
import 'package:untitled/pages/checkout.dart';
import 'package:untitled/pages/itempage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = cartList.fold(
        0, (sum, item) => sum + (item['price'] ?? 0)); // Calculate total price

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: cartList.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      final item = cartList[index];
                      final categoryIcon = _getCategoryIcon(item['category']); // Get category icon

                      return ListTile(
                        title: Row(
                          children: [
                            categoryIcon, // Add category icon
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(item['title'] ?? 'Untitled'),
                            ),
                          ],
                        ),
                        subtitle: null, // No subtitle, only the price and delete icon
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // To keep both price and delete icon tight
                          children: [
                            Text("₪${item['price'] ?? '0.00'}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),), // Display price next to the delete icon
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  cartList.removeAt(index); // Remove item and refresh the UI
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item['title']} removed from cart'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Navigate to ItemPage with API call
                          final itemId = item['_id']; // Assuming each item has an 'id'
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemPage(itemId: itemId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₪$totalPrice',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
    // Navigate to CheckoutPage and pass cart items and total price
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartList,
          totalPrice: totalPrice,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    backgroundColor: Colors.blue, // Solid blue button
  ),
  child: const Text(
    'Checkout',
    style: TextStyle(fontSize: 18, color: Colors.white),
  ),
),
                    
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }

  // Function to return category icon based on the category of the item
  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'CPU':
        return Image.asset('assets/icons/cpu.png', width: 40, height: 40);
      case 'GPU':
        return Image.asset('assets/icons/gpu.png', width: 40, height: 40);
      case 'Monitors':
        return Image.asset('assets/icons/monitor.png', width: 40, height: 40);
      case 'Motherboard':
        return Image.asset('assets/icons/motherboard.png', width: 40, height: 40);
      case 'RAM':
        return Image.asset('assets/icons/ram.png', width: 40, height: 40);
      case 'Case':
        return Image.asset('assets/icons/case.png', width: 40, height: 40);
      case 'Hard Disk':
        return Image.asset('assets/icons/hard-disk.png', width: 40, height: 40);
      case 'Accessories':
        return Image.asset('assets/icons/accessorise.png', width: 40, height: 40);
      default:
        return Icon(Icons.category, color: Colors.grey); // Default icon
    }
  }
}
