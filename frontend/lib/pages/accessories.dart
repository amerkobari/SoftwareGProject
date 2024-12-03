import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/controllers/authController.dart'; // Adjust the path as necessary

class AccessoriesPage extends StatelessWidget {
  AccessoriesPage({super.key});

  // Instance of AuthController
  final AuthController authController = AuthController();
  final String baseUrl = 'http://10.0.2.2:3000/uploads'; // Backend URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accessories',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: authController.fetchItems('Accessories'), // Use fetchItems with 'cpu' category
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/accessorise.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  title: Text(item['title'] ?? 'No Title', // Title from schema
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['description'] ?? 'No Description'), // Description from schema
                  trailing: Text(
                    '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    // Navigate to ItemPage with API call
                    final itemId = item['_id']; // Assuming each item has an 'id'
                    //print the item id
                    print("ITEM IDDDDDDDDDDDDDDDDDDDDDDDD $itemId");
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
          );
        },
      ),
    );
  }
}