import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';

class CPUPage extends StatelessWidget {
  const CPUPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for testing
    final List<Map<String, dynamic>> mockItems = [
      {
        'name': 'Intel Core i9-12900K Processor',
        'description': 'The Intel Core i9-12900K is a high-performance processor...',
        'price': 599.99,
      },
      // Add more mock items if needed
    ];
    

    final mockItem = {
      'title': 'Intel Core i9-12900K Processor',
      'imageUrls': [
        'assets/icons/cpu.png',
        'assets/icons/gpu.png',
        'assets/icons/cpu.png',
        'assets/icons/case.png',
        
      ],
      'username': 'JohnDoe',
      'price': 599.99,
      'condition': 'New',
      'description': 'The Intel Core i9-12900K is a high-performance processor...',
      'location': 'New York, USA',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CPU',
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
      body: ListView.builder(
        itemCount: mockItems.length,
        itemBuilder: (context, index) {
          final item = mockItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.asset(
                'assets/icons/cpu.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              title: Text(item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['description']),
              trailing: Text(
                '\₪${item['price']}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Navigate to the detail page with the selected item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemPage(itemData: mockItem),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
