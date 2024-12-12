import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/Personalinfo.dart';
import 'package:untitled/pages/checkout.dart';
import 'package:untitled/pages/itempage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

final AuthController _authController = AuthController();

class _CartPageState extends State<CartPage> {
  // List<Map<String, dynamic>> cartList = [];
  bool isLoading = true;
  
  // Fetch username from token
  Future<String> getUsername() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] ?? 'Guest';
  }
String username = '';

Future<void> setUsername() async {
   username = await getUsername();
}

void checkAndRemoveFromCart(int index) async {
  String username = await getUsername();
  if (username == 'Guest') {
    cartList.removeAt(index);
  }
}


Future<void> _removeCartItem(String itemId, int index) async {
    final String baseUrl = 'http://10.0.2.2:3000/api/auth/removeCartItem';
    
final String username = await getUsername();
if (username == 'Guest') {
    cartList.removeAt(index);
    return;
  }
  else{

    try {

      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'itemId': itemId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from cart')),
        );
      } else {
        throw Exception('Failed to remove item: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item from cart')),
      );
    }
  }
}
  // Fetch cart data from the backend
 Future<void> _fetchCartItems() async {
  final String baseUrl = 'http://10.0.2.2:3000/api/auth/getCart';
  final String username = await getUsername();

  try {
    // If the user is a Guest, use the existing cartList
    if (username == 'Guest') {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // For authenticated users, fetch cart items from the database
    final response = await http.get(
      Uri.parse('$baseUrl?username=$username'),
      headers: {'Content-Type': 'application/json'},
    );

    print(username);
    print("This is the response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['items'] != null) {
        List<dynamic> items = data['items'];
        List<Map<String, dynamic>> parsedCartItems = items.map((item) {
          return {
            'itemId': item['itemId']['_id'],
            'title': item['itemId']['title'],
            'price': item['itemId']['price'],
            'description': item['itemId']['description'],
            'images': item['itemId']['images'] ?? [],
            'category': item['itemId']['category'],
            'addedAt': item['addedAt'],
          };
        }).toList();

        setState(() {
          cartList = parsedCartItems;
          print("Cart list is: $cartList");
          isLoading = false;
        });
      } else {
        setState(() {
          cartList = [];
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load cart data: ${response.body}');
    }
  } catch (e) {
    setState(() => isLoading = false);
    print('Error: $e');
  }
}


  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartList.fold(0, (sum, item) => sum + (item['price'] ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
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
          : cartList.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartList.length,
                        itemBuilder: (context, index) {
                          final item = cartList[index];
                          final categoryIcon = _getCategoryIcon(item['category']);

                          return ListTile(
                            title: Row(
                              children: [
                                categoryIcon,
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['title'] ?? 'Untitled',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "₪${item['price'] ?? '0.00'}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () async {
  await setUsername(); // Ensure username is set
  if (username == "Guest") {
    setState(() {
      cartList.removeAt(index); // Remove item for Guest
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['title']} removed from cart')),
    );
  } else {
    _removeCartItem(item['itemId'], index); // Remove item for authenticated user
  }
                                      
                                    
                                   
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item['title']} removed from cart'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              final itemId;
                              if(username=="Guest"){
                                itemId = item['_id'];
                              }
                              else{
                              itemId = item['itemId'];
                              }
                              
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ₪$totalPrice',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    cartItems: cartList,
                                    totalPrice: totalPrice,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color.fromARGB(255, 254, 111, 103),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }

  // Get category icon based on category
  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'CPU':
        return Image.asset('assets/icons/cpu.png', width: 40, height: 40);
      case 'GPU':
        return Image.asset('assets/icons/gpu.png', width: 40, height: 40);
      case 'Monitors':
        return Image.asset('assets/icons/monitor.png', width: 40, height: 40);
      case 'Motherboard':
        return Image.asset('assets/icons/motherboard.png', width: 40, height: 40);
      case 'RAM':
        return Image.asset('assets/icons/ram.png', width: 40, height: 40);
      case 'Case':
        return Image.asset('assets/icons/case.png', width: 40, height: 40);
      case 'Hard Disk':
        return Image.asset('assets/icons/hard-disk.png', width: 40, height: 40);
      case 'Accessories':
        return Image.asset('assets/icons/accessorise.png', width: 40, height: 40);
      default:
        return const Icon(Icons.category, color: Colors.grey);
    }
  }
}
