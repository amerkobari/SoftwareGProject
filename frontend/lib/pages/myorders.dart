import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

final AuthController _authController = AuthController();

class _OrdersPageState extends State<OrdersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> ordersList = [];

  // Fetch username from token
  Future<String> getUsername() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] ?? 'Guest';
  }

  // Fetch orders data from the backend
  Future<void> _fetchOrders() async {
    final String baseUrl = 'http://10.0.2.2:3000/api/auth/getOrders';
    final String username = await getUsername();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?username=$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['orders'] != null) {
          List<dynamic> items = data['orders'];
          List<Map<String, dynamic>> parsedOrders = items.map((item) {
            return {
              'orderId': item['_id'],
              'items': item['items'],
              'totalPrice': item['totalPrice'],
              'orderDate': item['orderDate'],
            };
          }).toList();

          setState(() {
            ordersList = parsedOrders;
            isLoading = false;
          });
        } else {
          setState(() {
            ordersList = [];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load orders: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
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
          : ordersList.isNotEmpty
              ? ListView.builder(
                  itemCount: ordersList.length,
                  itemBuilder: (context, index) {
                    final order = ordersList[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          'Order #${order['orderId']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ₪${order['totalPrice'] ?? '0.00'}'),
                            Text('Date: ${order['orderDate'] ?? 'Unknown'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_border, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(orderId: order['orderId']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'You have no orders!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details - #$orderId'),
      ),
      body: Center(
        child: Text('Details for order #$orderId'),
      ),
    );
  }
}
