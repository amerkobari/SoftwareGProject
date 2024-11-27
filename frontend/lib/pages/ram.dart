import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/controllers/authController.dart'; // Adjust the path as necessary

class RAMPage extends StatelessWidget {
  RAMPage({super.key});

  // Instance of AuthController
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RAM',
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
        // Fetching RAM items from the database
        future: authController
            .fetchItems('RAM'), // Use fetchItems with 'RAM' category
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
                  leading: item['images'] != null && item['images'].isNotEmpty
                      ? Image.network(
                          item['images'][
                              0], // Display the first image from the images array
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          'assets/icons/ram.png', // Default image if no image is available
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                  title: Text(item['title'] ?? 'No Title', // Title from schema
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    item['description'] ??
                        'No Description', // Description from schema
                  ),
                  trailing: Text(
                    '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}', // Price from schema
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemPage(itemData: item),
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
