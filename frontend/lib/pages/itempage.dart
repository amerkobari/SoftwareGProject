import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
import 'dart:convert';
import 'dart:typed_data';

class ItemPage extends StatefulWidget {
  final String itemId; // Pass only item ID instead of the entire item data

  const ItemPage({super.key, required this.itemId});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _itemData; // Holds item data fetched from the backend
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    try {
      final itemDetails = await _authController.getItemById(widget.itemId);
      setState(() {
        _itemData = itemDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load item details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: Text(_itemData?['title'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _itemData == null
              ? const Center(child: Text('Item not found')) // Handle case where item data is null
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display images as a carousel or scrollable list
                SizedBox(
  height: 200,
  child: _itemData?['imageUrls'] == null || _itemData!['imageUrls'].isEmpty
      ? const Center(child: Text('No images available'))
      : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _itemData!['imageUrls'].length,
          itemBuilder: (context, index) {
            final image = _itemData!['imageUrls'][index];
            // Check if image is base64 encoded
            if (image is String && image.startsWith('data:')) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.memory(
                  Base64Decoder().convert(image.split(',')[1]), // Convert base64 to byte array
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const SizedBox(); // Handle invalid base64 or null image
            }
          },
        ),
),
                      
                      const SizedBox(height: 16),
                      Text(
                        _itemData!['title'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Seller: ${_itemData!['username']}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Price: ₪${_itemData!['price']}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Condition: ${_itemData!['condition']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Description:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _itemData!['description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Location: ${_itemData!['location']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle "Add to Cart"
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${_itemData!['title']} added to cart!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue, // Solid blue button
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
