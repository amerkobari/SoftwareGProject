import 'package:flutter/material.dart';
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

  // Function to fetch user items
  Future<void> _fetchUserItems() async {
    setState(() {
      _isLoadingItems = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/items-sold/${widget.userName}'));
      if (response.statusCode == 200) {
        setState(() {
          _userItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
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

  // Function to fetch user data (balance, orders)
  Future<Map<String, dynamic>> fetchData(String username) async {
    final responseBalance = await http.get(Uri.parse('$baseUrl/api/auth/user-balance/$username'));
    final responseCount = await http.get(Uri.parse('$baseUrl/api/auth/count-items-sold/$username'));

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
    _fetchUserItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 254, 111,103),
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add right padding
            child: IconButton(
              icon: const Icon(
                Icons.history,
                color: Colors.white, // Icon color set to white
              ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  if (_isLoadingItems) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_userItems.isEmpty) {
                    return const Center(
                      child: Text('No items sold yet.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: _userItems.length,
                    itemBuilder: (context, index) {
                      final item = _userItems[index];
                      final category = item['category'] ?? 'Other';

                      return ListTile(
                        leading: Image.asset(
                          _getCategoryIcon(category),
                          width: 40,
                          height: 40,
                        ),
                        title: Text(item['title'] ?? 'No Title'),
                        subtitle: Text(item['description'] ?? 'No Description'),
                        trailing: Text(
                          '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
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
                  const Icon(Icons.account_circle, size: 140, color: Color.fromARGB(255, 254, 111,103)),
                  const SizedBox(height: 8),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                              const Text('Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('\$$balance', style: const TextStyle(fontSize: 16, color: Colors.blue)),
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
                              const Text('Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('$orders', style: const TextStyle(fontSize: 16, color: Colors.green)),
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
                              builder: (context) => PersonalInfoPage(username: widget.userName),
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
                              builder: (context) => UserItemsPage(userName: widget.userName),
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
                              builder: (context) => const HomePage(username: 'Guest'),
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
