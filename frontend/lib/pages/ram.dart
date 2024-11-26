import 'package:flutter/material.dart';

class RAMPage extends StatelessWidget {
  const RAMPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for testing
    final List<Map<String, dynamic>> mockItems = [
      {
        'name': 'Intel Core i9-12900K',
        'description': '16-Core, 3.2 GHz, LGA 1700 Socket',
        'price': 599.99
      },
      {
        'name': 'AMD Ryzen 9 5950X',
        'description': '16-Core, 3.4 GHz, AM4 Socket',
        'price': 549.99
      },
      {
        'name': 'Intel Core i5-12600K',
        'description': '10-Core, 3.7 GHz, LGA 1700 Socket',
        'price': 319.99
      },
      {
        'name': 'AMD Ryzen 5 5600X',
        'description': '6-Core, 3.7 GHz, AM4 Socket',
        'price': 199.99
      },
    ];

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
                'assets/icons/ram.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['description']),
              trailing: Text(
                '\₪${item['price']}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
