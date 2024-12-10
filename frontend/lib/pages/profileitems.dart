import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/edititempage.dart';
import 'package:untitled/pages/itemPage.dart'; // Import the ItemPage

class UserItemsPage extends StatefulWidget {
  final String userName;

  const UserItemsPage({super.key, required this.userName});

  @override
  _UserItemsPageState createState() => _UserItemsPageState();
}

class _UserItemsPageState extends State<UserItemsPage> {
  final AuthController authController = AuthController();
  List<Map<String, dynamic>> _userItems = [];

  @override
  void initState() {
    super.initState();
    _fetchUserItems();
  }

  Future<void> _fetchUserItems() async {
    try {
      final items = await authController.fetchuserItems(widget.userName);
      setState(() {
        _userItems = items;
      });
    } catch (e) {
      print("Error fetching user items: $e");
    }
  }

  // Function to get the category icon based on category name
  String _getCategoryIcon(String? category) {
    // Define a mapping of categories to icon paths
    const categoryIcons = {
      'CPU': 'assets/icons/cpu.png',
      'Case': 'assets/icons/case.png',
      'GPU': 'assets/icons/gpu.png',
      'RAM': 'assets/icons/ram.png',
      'Motherboard': 'assets/icons/motherboard.png',
      'Hard Disk': 'assets/icons/hard-disk.png',
      'Monitors': 'assets/icons/monitor.png',
      'Accessories': 'assets/icons/accessorise.png',
      // Add more categories as needed
    };

    // Return the corresponding icon or a default icon if category is not found
    return categoryIcons[category] ?? 'assets/icons/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Items',
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
      body: _userItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _userItems.length,
              itemBuilder: (context, index) {
                final item = _userItems[index];
                final category = item['category'] ?? 'Other';

                return ListTile(
                  leading: Image.asset(
                    _getCategoryIcon(category), // Fetch the icon based on the category
                    width: 40, // Icon width
                    height: 40, // Icon height
                  ),
                  title: Text(item['title'] ?? 'No Title'),
                  subtitle: Text(item['description'] ?? 'No Description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
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
                    final itemId = item['_id']; // Get the item ID
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
    authController.removeItem(itemId).then((response) {
      if (response['success']) {
        setState(() {
          _userItems.removeWhere((item) => item['_id'] == itemId);
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