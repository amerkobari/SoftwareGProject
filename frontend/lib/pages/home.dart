import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled/pages/accessories.dart';
import 'package:untitled/pages/addnewitem.dart';
import 'package:untitled/pages/case.dart';
import 'package:untitled/pages/cpu.dart';
import 'package:untitled/pages/gpu.dart';
import 'package:untitled/pages/hard-disk.dart';
import 'package:untitled/pages/login.dart';
import 'package:untitled/pages/monitor.dart';
import 'package:untitled/pages/motherboard.dart';
import 'package:untitled/pages/ram.dart'; // Make sure to include this import for SVG support

class HomePage extends StatefulWidget {
  final String username; // Add a username field

  const HomePage(
      {super.key, required this.username}); // Add the required parameter

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
            color: const Color(0xff1D1617).withOpacity(0.18),
            blurRadius: 45,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchField(),
              const SizedBox(height: 20),
              // Categories Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Horizontal Swipable Categories
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryCard('CPU', 'assets/icons/cpu.png'),
                    _categoryCard('GPU', 'assets/icons/gpu.png'),
                    _categoryCard('RAM', 'assets/icons/ram.png'),
                    _categoryCard('Hard Disk', 'assets/icons/hard-disk.png'),
                    _categoryCard('Motherboards', 'assets/icons/motherboard.png'),
                    _categoryCard('Case', 'assets/icons/case.png'),
                    _categoryCard('Monitors', 'assets/icons/monitor.png'),
                    _categoryCard('Accessories', 'assets/icons/accessorise.png'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Shops Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Shops',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Horizontal Swipable Shops
              SizedBox(
                height:
                    150, // Increase the height to accommodate larger shop cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _shopCard('Tech Shop', Icons.store),
                    _shopCard('Gadget World', Icons.storefront),
                    _shopCard('Smartphones Plus', Icons.phone_android),
                    _shopCard('Camera Zone', Icons.camera),
                    _shopCard('Gaming Hub', Icons.videogame_asset),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
      ],
    );
  }

  // Helper Function for Category Cards with Random Colors
  Widget _categoryCard(String categoryName, String imagePath) {
  final random = Random();
  final color = Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    0.3, // Semi-transparent color
  );

  // Determine custom size for RAM and Accessories
  double imageSize = (categoryName == 'RAM' ) ? 40 : 40;

  return GestureDetector(
    onTap: () {
      // Navigate to the corresponding page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            switch (categoryName) {
              case 'CPU':
                return CPUPage();
              case 'GPU':
                return GPUPage();
              case 'RAM':
                return RAMPage();
              case 'Hard Disk':
                return HardDiskPage();
              case 'Motherboards':
                return MotherboardPage();
              case 'Case':
                return CasePage();
              case 'Monitors':
                return MonitorsPage();
              case 'Accessories':
                return AccessoriesPage();
              default:
                return HomePage(username: widget.username);
            }
          },
        ),
      );
    },
    child: Container(
      width: 120,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imageSize,
            width: imageSize,
          ),
          const SizedBox(height: 10),
          Text(
            categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}




  // Helper Function for Shop Cards
  // Helper Function for Shop Cards with Bigger Size
  Widget _shopCard(String shopName, IconData iconData) {
    return Container(
      width: 180, // Increased width
      height: 200, // Increased height
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 60, color: Colors.black), // Enlarged icon
          const SizedBox(height: 10),
          Text(
            shopName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16, // Slightly larger font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HardwareBazaar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
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
                      child: Icon(Icons.account_circle,
                          size: 100, color: Colors.white),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.black),
                title: const Text('Favorites'),
                onTap: () {
                  // Navigate to cart
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
                leading: const Icon(Icons.store, color: Colors.black),
                title: const Text('My Shops'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.black),
                title: const Text('Add New Item'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddItemPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_business, color: Colors.black),
                title: const Text('Add New Shop'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
