import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled/pages/login.dart'; // Make sure to include this import for SVG support

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
          fillColor: Colors.white, // White background for the search bar
          contentPadding: const EdgeInsets.all(15),
          hintText:
              'Search Hardware', // You can change this to your own search text
          hintStyle: const TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
                'assets/icons/Search.svg'), // Update with your icon
          ),
          suffixIcon: Container(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Return the filter icon to the right
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  GestureDetector(
                    onTap: _showFilterDialog, // Show the filter popup on tap
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: SvgPicture.asset(
                        'assets/icons/Filter.svg',
                        width:
                            30, // Make the icon bigger by adjusting the width
                        height:
                            30, // Adjust height to make the icon proportional
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select your filter criteria here.'),
              // Add more filter options as needed
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Apply the filter logic here
                Navigator.of(context).pop(); // Close the dialog
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
        // Main Home Page Content
        SingleChildScrollView(
          child: Column(
            children: [
              // Home page content starts here
              Container(
                height: 600, // Adjust the size as per your content
                width: double.infinity, // Make the content fill the width
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background to white
                ),
                child: Center(
                  child: Text(
                    'Home Page Content',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search bar that will appear above the content with box shadow
        _searchField(),
      ],
    );
  }

  // Content for MessagesPage (unchanged)
  Widget _messagesPageContent() {
    return Center(
      child: Text('Messages Page Content'),
    );
  }

  // Content for CommunityPage (unchanged)
  Widget _communityPageContent() {
    return Center(
      child: Text('Community Page Content'),
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
      backgroundColor:
          Colors.white, // Set the background color of the scaffold to white
      body: _selectedIndex == 0
          ? _homePageContent() // Home page content with search bar and filter
          : _selectedIndex == 1
              ? _messagesPageContent() // Messages page content (unchanged)
              : _communityPageContent(), // Community page content (unchanged)
      drawer: Drawer(
        child: Container(
          color: Colors.white, // Set drawer background color to white
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    // Use a Flexible widget to prevent overflow
                    Flexible(
                      flex: 2,
                      child: Icon(Icons.account_circle,
                          size: 100, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      flex: 1,
                      child: Text(
                        'User Name', // Replace with dynamic user data
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text('Profile'),
                onTap: () {
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.black),
                title: Text('My Cart'),
                onTap: () {
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: Icon(Icons.add_business, color: Colors.black),
                title: Text('Add New Shop'),
                onTap: () {
                  // Navigate to add new shop
                },
              ),
              ListTile(
                leading: Icon(Icons.add, color: Colors.black),
                title: Text('Add New Item'),
                onTap: () {
                  // Navigate to add new item
                },
              ),
              ListTile(
                leading: Icon(Icons.store, color: Colors.black),
                title: Text('My Shops'),
                onTap: () {
                  // Navigate to my shops
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.black),
                title: Text('Logout'),
                onTap: () {
                  // Navigate to Login page
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
