import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled/pages/login.dart'; // Make sure to include this import for SVG support

class HomePage extends StatefulWidget {
  final String username; // Add a username field

  const HomePage({super.key, required this.username}); // Add the required parameter

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Search Bar Widget
  Container _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Search Hardware',
          hintStyle: const TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset('assets/icons/Search.svg'),
          ),
          suffixIcon: SizedBox(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: SvgPicture.asset(
                        'assets/icons/Filter.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Method to show filter popup
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select your filter criteria here.'),
              TextField(
                decoration: InputDecoration(hintText: 'Filter by price'),
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Filter by category'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Content for HomePage with BoxShadow on Search Bar
  Widget _homePageContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 600,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'Home Page Content',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        _searchField(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HardwareBazzar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                // Handle notification tap
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _selectedIndex == 0
          ? _homePageContent()
          : _selectedIndex == 1
              ? const Center(child: Text('Messages Page Content'))
              : const Center(child: Text('Community Page Content')),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Icon(Icons.account_circle, size: 100, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      flex: 1,
                      child: Text(
                        widget.username, // Display the logged-in username here
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.black),
                title: const Text('Profile'),
                onTap: () {
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.black),
                title: const Text('My Cart'),
                onTap: () {
                  // Navigate to cart
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_business, color: Colors.black),
                title: const Text('Add New Shop'),
                onTap: () {
                  // Navigate to add new shop
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.black),
                title: const Text('Add New Item'),
                onTap: () {
                  // Navigate to add new item
                },
              ),
              ListTile(
                leading: const Icon(Icons.store, color: Colors.black),
                title: const Text('My Shops'),
                onTap: () {
                  // Navigate to my shops
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}
