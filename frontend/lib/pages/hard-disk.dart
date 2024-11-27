import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/controllers/authController.dart'; // Adjust the path as necessary

class HardDiskPage extends StatelessWidget {
  HardDiskPage({super.key});

  // Instance of AuthController
  final AuthController authController = AuthController();
  final String baseUrl = 'http://10.0.2.2:3000/uploads'; // Backend URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hard Disks',
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
        // Fetching Hard Disk items from the database
        future: authController.fetchItems('Hard Disk'), // Use fetchItems with 'Hard Disk' category
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
              final imageUrl = item['images'] != null && item['images'].isNotEmpty
                  ? '$baseUrl/${item['images'][0]}' // Full URL to the image
                  : null; // Fallback to default asset

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/icons/harddisk.png', // Default icon if image fails to load
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/icons/harddisk.png', // Default icon if no image is available
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                  title: Text(
                    item['title'] ?? 'No Title', // Title from schema
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['description'] ?? 'No Description', // Description from schema
                  ),
                  trailing: Text(
                    '₪${item['price']?.toString() ?? 'N/A'}', // Price from schema
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ItemPage(itemData: item),
                    //   ),
                    // );
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
