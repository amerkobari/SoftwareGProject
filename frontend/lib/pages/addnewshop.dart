import 'package:flutter/material.dart';

class AddNewShopPage extends StatelessWidget {
  const AddNewShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Shop',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Shop Address',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle shop creation
                // For example, send the data to your API or save it locally
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shop added successfully!')),
                );
              },
              child: const Text(
                        'Add Shop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
