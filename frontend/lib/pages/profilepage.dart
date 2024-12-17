import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled/pages/Personalinfo.dart';
import 'package:untitled/pages/home.dart';
import 'package:untitled/pages/profileitems.dart';

class UserProfilePage extends StatefulWidget {
  final String userName;

  const UserProfilePage({super.key, required this.userName});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> userInfo;
  final String baseUrl = "http://10.0.2.2:3000";
  List<Map<String, dynamic>> _userItems = [];
  bool _isLoadingItems = true;
  late Future<double> userRating; // Add this to hold the rating

  // Function to fetch user items
  Future<void> _fetchUserItems() async {
    setState(() {
      _isLoadingItems = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/auth/items-sold/${widget.userName}'));
      if (response.statusCode == 200) {
        setState(() {
          _userItems =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to load user items');
      }
    } catch (e) {
      print("Error fetching user items: $e");
    } finally {
      setState(() {
        _isLoadingItems = false;
      });
    }
  }

  Future<double> fetchUserRating(String username) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/auth/ratings/$username'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[
          'averageRating']; // Assuming the response has the average rating
    } else {
      throw Exception('Failed to load user rating');
    }
  }

  // Function to fetch user data (balance, orders)
  Future<Map<String, dynamic>> fetchData(String username) async {
    final responseBalance =
        await http.get(Uri.parse('$baseUrl/api/auth/user-balance/$username'));
    final responseCount = await http
        .get(Uri.parse('$baseUrl/api/auth/count-items-sold/$username'));

    if (responseBalance.statusCode == 200 && responseCount.statusCode == 200) {
      return {
        'balance': jsonDecode(responseBalance.body)['balance'],
        'orders': jsonDecode(responseCount.body)['soldCount'],
      };
    } else {
      throw Exception('Failed to load user data');
    }
  }

  String _getCategoryIcon(String? category) {
    const categoryIcons = {
      'CPU': 'assets/icons/cpu.png',
      'Case': 'assets/icons/case.png',
      'GPU': 'assets/icons/gpu.png',
      'RAM': 'assets/icons/ram.png',
      'Motherboard': 'assets/icons/motherboard.png',
      'Hard Disk': 'assets/icons/hard-disk.png',
      'Monitors': 'assets/icons/monitor.png',
      'Accessories': 'assets/icons/accessories.png',
    };
    return categoryIcons[category] ?? 'assets/icons/default.png';
  }

  @override
  void initState() {
    super.initState();
    userInfo = fetchData(widget.userName);
    userRating = fetchUserRating(widget.userName); // Fetch user rating
    _fetchUserItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 254, 111, 103),
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    if (_isLoadingItems) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_userItems.isEmpty) {
                      return const Center(child: Text('No items sold yet.'));
                    }

                    return ListView.builder(
                      itemCount: _userItems.length,
                      itemBuilder: (context, index) {
                        final item = _userItems[index];
                        final category = item['category'] ?? 'Other';
                        final price = item['price']?.toDouble() ?? 0.0;

                        // Calculate the dynamic fee
                        double feePercentage;
                        if (price >= 1000) {
                          feePercentage = 8.0;
                        } else if (price >= 800) {
                          feePercentage = 7.0;
                        } else if (price >= 300) {
                          feePercentage = 5.0;
                        } else {
                          feePercentage = 3.0;
                        }

                        final fee = price * (feePercentage / 100);
                        final netPrice = price - fee;

                        return ListTile(
                          leading: Image.asset(
                            _getCategoryIcon(category),
                            width: 40,
                            height: 40,
                          ),
                          title: Text(item['title'] ?? 'No Title'),
                          subtitle:
                              Text(item['description'] ?? 'No Description'),
                          trailing: Text(
                            '₪${netPrice.toStringAsFixed(2)}', // Display net price after fee
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final balance = snapshot.data!['balance'];
            final orders = snapshot.data!['orders'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.account_circle,
                      size: 140, color: Color.fromARGB(255, 254, 111, 103)),
                  const SizedBox(height: 8),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Display the rating as stars below the username
                  FutureBuilder<double>(
                    future: userRating,
                    builder: (context, ratingSnapshot) {
                      if (ratingSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (ratingSnapshot.hasError) {
                        return Text('Error: ${ratingSnapshot.error}');
                      } else {
                        return Column(
                          children: [
                            RatingBar.builder(
                              initialRating: ratingSnapshot.data ?? 0.0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Color.fromARGB(255, 255, 191, 0),
                              ),
                              onRatingUpdate:
                                  (value) {}, // No need to handle updates
                              ignoreGestures:
                                  true, // Make it static (uneditable)
                            ),
                            // const SizedBox(height: 16),
                            // Text(
                            //   'Average Rating: ${ratingSnapshot.data?.toStringAsFixed(1) ?? 'N/A'}',
                            //   style: const TextStyle(fontSize: 16, color: Colors.black),
                            // ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              const Text('Balance',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('\$$balance',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              const Text('Orders',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('$orders',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Personal Information'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PersonalInfoPage(username: widget.userName),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: const Text('Your Items'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserItemsPage(userName: widget.userName),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HomePage(username: 'Guest'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
