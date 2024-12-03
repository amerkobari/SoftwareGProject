import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/addnewitem.dart';
import 'package:untitled/pages/edititempage.dart';
import 'package:untitled/pages/itempage.dart';

class OwnerShopPage extends StatefulWidget {
  final String shopId;

  const OwnerShopPage({super.key, required this.shopId});

  @override
  // ignore: library_private_types_in_public_api
  _OwnerShopPageState createState() => _OwnerShopPageState();
}

class _OwnerShopPageState extends State<OwnerShopPage> {
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
      final items = await _authController.fetchItemsShop(widget.shopId);
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

  // Function to add a new item
  void _addNewItem() {
    // Navigate to the add item page or show a dialog to add a new item
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(shopId: widget.shopId),
      ),
    );
  }

  // Function to edit an item
  void _editItem(Map<String, dynamic> item) {
    // Navigate to the edit item page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(itemId: item['_id']),
      ),
    );
  }

  // Function to remove an item
  void _removeItem(String itemId) {
    // Call the controller method to remove the item
    _authController.removeItem(itemId).then((response) {
      if (response['success']) {
        setState(() {
          _shopItems.removeWhere((item) => item['_id'] == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to remove item: ${response['message']}')),
        );
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.shopId);
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
                                  if (logoUrl is String &&
                                      logoUrl.startsWith('data:')) {
                                    return ClipOval(
                                      child: Image.memory(
                                        Base64Decoder()
                                            .convert(logoUrl.split(',')[1]),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else if (logoUrl is String) {
                                    return ClipOval(
                                      child: Image.network(
                                        logoUrl,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                    child: Icon(Icons.error,
                                                        size: 50)),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                        child: Text('Invalid logo format'));
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shopData!['shopName'],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Location: ${_shopData!['city']}, ${_shopData!['shopAddress']}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addNewItem,
                        child: const Text('Add New Item'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Items:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
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
                                    title: Text(item['title']),
                                    subtitle: Text("Price: \$${item['price']}"),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editItem(item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _showDeleteConfirmationDialog(context, item['_id']),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                    // Navigate to ItemPage with API call
                    final itemId = item['_id']; // Assuming each item has an 'id'
                    //print the item id
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemPage(itemId: itemId),
                      ),
                    );
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
  void _showDeleteConfirmationDialog(BuildContext context, String itemId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog without doing anything
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog and proceed with the deletion
              Navigator.of(context).pop();
              _removeItem(itemId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

}
