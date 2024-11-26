import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ItemPage({super.key, required this.itemData});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  // List to store items added to the cart
  final List<Map<String, dynamic>> _cart = [];

  // Method to add item to the cart
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cart.add(item);
    });
    // You could also show a snackbar or dialog to indicate item is added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['title']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        title: Text(widget.itemData['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display images as a carousel or scrollable list
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.itemData['imageUrls'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      widget.itemData['imageUrls'][index], // Display each image
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.itemData['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Seller: ${widget.itemData['username']}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              "Price: \$${widget.itemData['price']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Condition: ${widget.itemData['condition']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Description:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.itemData['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Location: ${widget.itemData['location']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addToCart(widget.itemData); // Add item to cart
              },
              child: const Text('Add to Cart', style: TextStyle(fontSize: 20, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blue, // Solid blue button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
