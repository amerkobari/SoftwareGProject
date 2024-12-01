import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:untitled/controllers/authController.dart';

class ShopPage extends StatefulWidget {
  final String shopId;

  const ShopPage({super.key, required this.shopId});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _shopData;
  List<Map<String, dynamic>> _shopItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    try {
      // Fetch shop details
      final shopDetails = await _authController.getShopById(widget.shopId);
      setState(() {
        _shopData = shopDetails['shop'];
      });

      // Fetch items of the shop
      final items = await _authController.fetchItems(widget.shopId);
      setState(() {
        _shopItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shop details: $e')),
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
        title: Text(_shopData?['shopName'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shopData == null
              ? const Center(child: Text('Shop not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop details
                     SizedBox(
  height: 200,
  child: _shopData?['logoUrl'] == null
      ? const Center(child: Text('No logo available'))
      : Builder(
          builder: (context) {
            final logoUrl = _shopData!['logoUrl'];
            // Check if the logo is base64-encoded
            if (logoUrl is String && logoUrl.startsWith('data:')) {
              return ClipOval(
                child: Image.memory(
                  Base64Decoder().convert(logoUrl.split(',')[1]),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              );
            } else if (logoUrl is String) {
              // If logo is a URL
              return ClipOval(
                child: Image.network(
                  logoUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error, size: 50)),
                ),
              );
            } else {
              return const Center(child: Text('Invalid logo format'));
            }
          },
        ),
),

                      const SizedBox(height: 16),
                      Text(
                        _shopData!['shopName'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Location: ${_shopData!['city']}, ${_shopData!['shopAddress']}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Email: ${_shopData!['email']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Phone: ${_shopData!['phoneNumber']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Description:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _shopData!['description'] ?? 'No description provided',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Items:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Items list
                      _shopItems.isEmpty
                          ? const Text('No items available')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _shopItems.length,
                              itemBuilder: (context, index) {
                                final item = _shopItems[index];
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(item['itemName']),
                                    subtitle: Text("Price: \$${item['price']}"),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () {
                                      // Handle item click, navigate to item details page
                                    },
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}
