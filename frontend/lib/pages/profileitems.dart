import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
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
                  trailing: Text(
                    '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
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
}