import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';

class FavoritesPage extends StatelessWidget {
  // Mock list of favorite items
  final List<Map<String, String>> favoriteItems = [
    {'title': 'Item 1', 'subtitle': 'Description of Item 1'},
    {'title': 'Item 2', 'subtitle': 'Description of Item 2'},
    {'title': 'Item 3', 'subtitle': 'Description of Item 3'},
    {'title': 'Item 4', 'subtitle': 'Description of Item 4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
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
     body: favoritesList.isNotEmpty
          ? ListView.builder(
              itemCount: favoritesList.length,
              itemBuilder: (context, index) {
                final item = favoritesList[index];
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      favoritesList.removeAt(index); // Remove item
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['title']} removed!')),
                      );
                      (context as Element).markNeedsBuild(); // Refresh UI
                    },
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
                );
              },
            )
          : const Center(
              child: Text(
                'No favorites yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }
}