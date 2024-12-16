import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/profilepage.dart';
import 'dart:convert';
import 'package:untitled/pages/userpage.dart';
import 'package:http/http.dart' as http;

List<Map<String, dynamic>> favoritesList = [];
List<Map<String, dynamic>> cartList = [];

class ItemPage extends StatefulWidget {
  final String itemId;

  const ItemPage({super.key, required this.itemId});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final AuthController _authController = AuthController();
  bool isFavorite = false;
  Map<String, dynamic>? _itemData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    try {
      final itemDetails = await _authController.getItemById(widget.itemId);
      setState(() {
        _itemData = itemDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load item details: $e')),
      );
    }
  }

  Future<String> getUsername() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String username = decodedToken['username'] ?? 'Guest';
    return username;
  }

  Future<void> _toggleFavorite() async {
    if (_itemData == null) return;

    final username = await getUsername();

    if (username == 'Guest') {
      setState(() {
       isFavorite = favoritesList.any((item) => item['_id'] == widget.itemId);
        if (isFavorite) {
          favoritesList.removeWhere((item) => item['_id'] == widget.itemId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed from favorites')),
          );
        } else {
          favoritesList.add(_itemData!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to favorites')),
          );
        }
      });
      return;
    }

   isFavorite = favoritesList.any((item) => item['_id'] == widget.itemId);
    final apiUrl = isFavorite
        ? 'http://10.0.2.2:3000/api/auth/removeFavorite'
        : 'http://10.0.2.2:3000/api/auth/addToFavorites';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'itemId': widget.itemId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (isFavorite) {
            favoritesList.removeWhere((item) => item['_id'] == widget.itemId);
            
          } else {
            favoritesList.add(_itemData!);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites')),
        );
      } else {
        throw Exception('Failed to update favorites: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool Favis = favoritesList.any((item) => item['_id'] == widget.itemId);
    // print(favoritesList);
    // print(Favis);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 254, 111, 103),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: Text(_itemData?['title'] ?? 'Loading...'),
        actions: [
          IconButton(
            icon: Icon(
              Favis ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
        onPressed: () {
              setState(() {
                _toggleFavorite();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itemData == null
              ? const Center(child: Text('Item not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: _itemData?['imageUrls'] == null ||
                                _itemData!['imageUrls'].isEmpty
                            ? const Center(child: Text('No images available'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _itemData!['imageUrls'].length,
                                itemBuilder: (context, index) {
                                  final image = _itemData!['imageUrls'][index];
                                  if (image is String &&
                                      image.startsWith('data:')) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Image.memory(
                                        Base64Decoder()
                                            .convert(image.split(',')[1]),
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _itemData!['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₪',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 254, 111, 103),
                                  ),
                                ),
                                TextSpan(
                                  text: _itemData!['price'].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          getUsername().then((username) {
                            if (username == _itemData!['username']) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfilePage(userName: username),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserPage(
                                      userName: _itemData!['username']),
                                ),
                              );
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Seller: ${_itemData!['username']}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 254, 111, 103)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Condition: ${_itemData!['condition']}",
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text("Description:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_itemData!['description'],
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 254, 111, 103),
                              size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _itemData!['location'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                     const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_itemData == null) return;

                          // Get the username asynchronously
                          final username = await getUsername();

                          // If the username is "guest", add to the local cartList instead of calling the backend
                          if (username == 'Guest') {
                            // Check if the item is already in the local cart list
                            if (!cartList.any((item) => item['_id'] == _itemData?['_id'])) {
                              // Add the item to the local cart list
                              cartList.add(_itemData!);

                              // Notify the user that the item has been added to the local cart
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${_itemData!['title']} added to cart!'),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${_itemData!['title']} is already in the cart!'),
                              ));
                            }
                          } else {
                            // If the user is not a guest, proceed with adding the item to the database (via addtoCart)
                            final msg = await _authController.addtoCart(_itemData!['_id'], getUsername());

                            // Show SnackBar with the message returned from addtoCart
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(msg),  // Use the message returned from addtoCart
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Color.fromARGB(255, 254, 111, 103),
                        ),
                        child: const Text('Add to Cart',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
