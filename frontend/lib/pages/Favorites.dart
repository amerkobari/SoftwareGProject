import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

final AuthController _authController = AuthController();

class _FavoritesPageState extends State<FavoritesPage> {
  bool isLoading = true;
  // List<Map<String, dynamic>> favoritesList = [];
  String username = '';

  // Fetch username from token
  Future<String> getUsername() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] ?? 'Guest';
  }

  // Fetch favorites from the backend
  Future<void> _fetchFavorites() async {
    const String baseUrl = 'http://10.0.2.2:3000/api/auth/getFavorites';
    username = await getUsername();

    try {
      if (username == 'Guest') {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl?username=$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['items'] != null) {
          setState(() {
            favoritesList = List<Map<String, dynamic>>.from(
              data['items'].map((item) => {
                    'itemId': item['itemId']['_id'],
                    'title': item['itemId']['title'],
                    'description': item['itemId']['description'],
                    'images': item['itemId']['images'] ?? [],
                    'category': item['itemId']['category'],
                    'addedAt': item['addedAt'],
                  }),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            favoritesList = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load favorites: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  // Remove a favorite item
  Future<void> _removeFavorite(String itemId, int index) async {
    const String baseUrl = 'http://10.0.2.2:3000/api/auth/removeFavorite';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'itemId': itemId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          favoritesList.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from favorites')),
        );
      } else {
        throw Exception('Failed to remove favorite: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item from favorites')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritesList.isNotEmpty
              ? ListView.builder(
                  itemCount: favoritesList.length,
                  itemBuilder: (context, index) {
                    final item = favoritesList[index];
                    return ListTile(
                      title: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['title'] ?? 'Untitled',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () async {
                          if (username == 'Guest') {
                            setState(() {
                              favoritesList.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['title']} removed from favorites'),
                              ),
                            );
                          } else {
                            await _removeFavorite(item['itemId'], index);
                          }
                        },
                      ),
                      onTap: () {
                        final itemId = username == "Guest"
                            ? item['_id']
                            : item['itemId'];
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
