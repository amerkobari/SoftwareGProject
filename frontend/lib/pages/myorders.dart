import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';
 final String baseUrl = "http://10.0.2.2:3000"; // Replace with your backend URL


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

final AuthController _authController = AuthController();

class _OrdersPageState extends State<OrdersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> ordersList = [];
  // Fetch email from token
  Future<String> getEmail() async {
    String token = await _authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['email'] ?? 'Guest';
  }



  // Fetch orders data from the backend
  Future<void> _fetchOrders() async {
    final String baseUrl = 'http://10.0.2.2:3000/api/auth/get-orders-by-email';
    final String email = await getEmail();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$email'),
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
              'totalPrice': item['total'],
              'orderDate': item['createdAt'],
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
                            // const Icon(Icons.star_border, color: Colors.orange),
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

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic> orderDetails = {};

  // Fetch order details by orderId from the API
  Future<void> _fetchOrderDetails() async {
    final String baseUrl = 'http://10.0.2.2:3000/api/auth/order-details/${widget.orderId}';

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['order'] != null) {
          setState(() {
            orderDetails = data['order'];
            print(orderDetails);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details - #${widget.orderId}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderDetails.isNotEmpty
              ? ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    // Display order basic details
                    ListTile(
                      title: Text(
                        'Name: ${orderDetails['firstName'] ?? 'N/A'} ${orderDetails['lastName'] ?? 'N/A'}',
                      ),
                    ),
                    ListTile(
                      title: Text('Email: ${orderDetails['email'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Delivery Address: ${orderDetails['deliveryAddress'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('City: ${orderDetails['city'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Phone Number: ${orderDetails['phoneNumber'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Total: ₪${orderDetails['total'] ?? '0.00'}'),
                    ),
                    const SizedBox(height: 20),
                    // Display order items
                    const Text(
                      'Items Ordered:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ...((orderDetails['items'] ?? []).map<Widget>((item) {
                      final categoryIcon = _getCategoryIcon(item['category'] ?? 'Unknown');
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: categoryIcon, // Use category icon here
                          title: Text(item['name'] ?? 'Untitled'),
                          subtitle: Text('Price: ₪${item['price'] ?? '0.00'}'),
                          trailing: Icon(Icons.star, color: Colors.orange),
                          onTap: () 
                          {
                            print(item['itemId']); 
                            showRatingDialog(context, item['itemId']);
                            
                          },
                        ),
                      );
                    }) ?? []),
                  ],
                )
              : const Center(
                  child: Text(
                    'Order not found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }

void showRatingDialog(BuildContext context, String itemId) {
  double rating = 0; // Initialize rating

  // Function to handle the API call for rating
  Future<void> rateSeller(double rating) async {
    final apiUrl = '$baseUrl/api/auth/updateAverageRating'; // Replace with your API URL

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemId': itemId,  // User's username
          'rating': rating,      // Rating value
        }),
      );

      if (response.statusCode == 200) {
        // Rating was successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your rating!')),
        );
      } else {
        // Handle error (e.g., failed API request)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: ${response.body}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }


   // Show the rating dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Rate Seller"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please rate the Seller:"),
            RatingBar.builder(
              initialRating: 0,
              minRating: 0.5,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.orange,
              ),
              onRatingUpdate: (value) {
                rating = value; // Update rating value
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Call the API to rate the seller when the submit button is pressed
              rateSeller(rating); // Pass the rating value
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
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



