import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
import 'dart:convert';

List<Map<String, dynamic>> favoritesList = [];
List<Map<String, dynamic>> cartList = [];

class ItemPage extends StatefulWidget {
  final String itemId;

  const ItemPage({super.key, required this.itemId});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _itemData;
  bool _isLoading = true;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load item details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the item is already in the favorites list
    bool isItemFavorite = favoritesList.any((item) => item['_id'] == widget.itemId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: Text(_itemData?['title'] ?? 'Loading...'),
        actions: [
          IconButton(
            icon: Icon(
              isItemFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {
              setState(() {
                // Toggle the favorite status
                if (isItemFavorite) {
                  favoritesList.removeWhere((item) => item['_id'] == widget.itemId); // Remove from favorites
                } else {
                  favoritesList.add(_itemData!); // Add to favorites
                }
              });

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isItemFavorite
                        ? 'Removed from favorites'
                        : 'Added to favorites',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itemData == null
              ? const Center(child: Text('Item not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: _itemData?['imageUrls'] == null ||
                                _itemData!['imageUrls'].isEmpty
                            ? const Center(child: Text('No images available'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _itemData!['imageUrls'].length,
                                itemBuilder: (context, index) {
                                  final image = _itemData!['imageUrls'][index];
                                  if (image is String && image.startsWith('data:')) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Image.memory(
                                        Base64Decoder().convert(image.split(',')[1]),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
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
                      Text("Seller: ${_itemData!['username']}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Text("Price: ₪${_itemData!['price']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Condition: ${_itemData!['condition']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_itemData!['description'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Text("Location: ${_itemData!['location']}", style: const TextStyle(fontSize: 16)),
                      ElevatedButton(
                        onPressed: () {
                          if (!cartList.any((item) => item['_id'] == _itemData!['_id'])) {
                            cartList.add(_itemData!);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_itemData!['title']} added to cart!')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_itemData!['title']} is already in the cart!')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
