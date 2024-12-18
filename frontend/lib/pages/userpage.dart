import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/chatscreen.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/pages/login.dart';

class UserPage extends StatefulWidget {
  final String userName;

  const UserPage({super.key, required this.userName});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final AuthController authController = AuthController();
  List<Map<String, dynamic>> _userItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _selectedSort = 'Newest to Oldest'; // Default sort option
  RangeValues _priceRange = const RangeValues(0, 10000); // Default price range
   double _averageRating = 0.0;  // Store the average rating here 

  @override
  void initState() {
    super.initState();
    _fetchUserItems();
    _fetchUserRating();
  }

  Future<String> getsenderUser() async {
    String token = await authController.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] ?? 'Guest';
  }
String senderuser = '';

Future<void> setsenderUser() async {
   senderuser = await getsenderUser();
   print("this is from the function setsenderuser : $senderuser");
}



Future<String> getOrCreateChatRoom(String currentUserName, String otherUserName) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query for existing chatroom containing both usernames
  QuerySnapshot query = await firestore
      .collection('Chatrooms')
      .where('userNames', arrayContains: currentUserName)
      .get();

  for (var doc in query.docs) {
    List<dynamic> userNames = doc['userNames'];
    if (userNames.contains(otherUserName)) {
      print("Chatroom already exists: ${doc.id}");
      return doc.id;
    }
  }

  // Create a new chatroom if it doesn't exist
  DocumentReference newChatRoom = await firestore.collection('Chatrooms').add({
    'userNames': [currentUserName, otherUserName],
    'lastMessage': "",
    'timestamp': FieldValue.serverTimestamp(),
    'notifications': {
      currentUserName: 0, // Track unread message count for current user
      otherUserName: 0,   // Track unread message count for the other user
    }
  });

  print("New chatroom created: ${newChatRoom.id}");
  return newChatRoom.id;
}

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text("You need to log in to start messaging."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  Future<void> _fetchUserRating() async {
    try {
      final data = await authController.fetchUserRating(widget.userName);
      setState(() {
        _averageRating = data['averageRating'] ?? 0.0;  // Get the average rating
      });
    } catch (e) {
      print("Error fetching user rating: $e");
    }
  }

  Future<void> _fetchUserItems() async {
    try {
      final items = await authController.fetchuserItems(widget.userName);
      setState(() {
        _userItems = items;
      });
    } catch (e) {
      print("Error fetching user items: $e");
    }
  }

  // Apply filters and sorting to items
  void _applyFilters() {
    setState(() {
      _filteredItems = List.from(_userItems); // Reset the filtered list

      // Apply sorting
      if (_selectedSort == 'Lowest to Highest Price') {
        _filteredItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (_selectedSort == 'Highest to Lowest Price') {
        _filteredItems.sort((a, b) => b['price'].compareTo(a['price']));
      } else if (_selectedSort == 'A-Z') {
        _filteredItems.sort((a, b) => a['title'].compareTo(b['title']));
      } else if (_selectedSort == 'Newest to Oldest') {
        _filteredItems.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));
      } else if (_selectedSort == 'Oldest to Newest') {
        _filteredItems.sort((a, b) => DateTime.parse(a['createdAt'])
            .compareTo(DateTime.parse(b['createdAt'])));
      }

      // Apply condition filter (New, Used)
      if (_selectedSort == 'New') {
        _filteredItems =
            _filteredItems.where((item) => item['condition'] == 'New').toList();
      } else if (_selectedSort == 'Used') {
        _filteredItems = _filteredItems
            .where((item) => item['condition'] == 'Used')
            .toList();
      }

      // Apply price range filter
      _filteredItems = _filteredItems
          .where((item) =>
              item['price'] >= _priceRange.start &&
              item['price'] <= _priceRange.end)
          .toList();
    });
  }

  // Show price range dialog
  void _showPriceRangeDialog(BuildContext context) {
    final TextEditingController startPriceController = TextEditingController(
      text: _priceRange.start.toStringAsFixed(0),
    );
    final TextEditingController endPriceController = TextEditingController(
      text: _priceRange.end.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Price Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Start Price',
                  prefixText: '₪',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: endPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'End Price',
                  prefixText: '₪',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final double? startPrice =
                    double.tryParse(startPriceController.text);
                final double? endPrice =
                    double.tryParse(endPriceController.text);

                if (startPrice != null &&
                    endPrice != null &&
                    startPrice <= endPrice) {
                  setState(() {
                    _priceRange = RangeValues(startPrice, endPrice);
                    _applyFilters();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid price range')),
                  );
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryIcon(String? category) {
    // Define a mapping of categories to icon paths
    const categoryIcons = {
      'CPU': 'assets/icons/cpu.png',
      'Case': 'assets/icons/case.png',
      'GPU': 'assets/icons/gpu.png',
      'RAM': 'assets/icons/ram.png',
      'Motherboard': 'assets/icons/motherboard.png',
      'Hard Disk': 'assets/icons/hard-disk.png',
      'Monitors': 'assets/icons/monitor.png',
      'Accessories': 'assets/icons/accessorise.png',
      // Add more categories as needed
    };

    // Return the corresponding icon or a default icon if category is not found
    return categoryIcons[category] ?? 'assets/icons/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 254, 111, 103),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
          centerTitle: true,
          
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.account_circle,
                size: 140, color: Color.fromARGB(255, 254, 111, 103)),
            const SizedBox(height: 8),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
//         const SizedBox(height: 16),
// // Display the average rating
// Text(
//   'Average Rating: ${_averageRating.toStringAsFixed(1)}',  // Display average rating
//   style: TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//     color: Colors.black,
//   ),
// ),
const SizedBox(height: 16),
Column(
  children: [
    const SizedBox(height: 16),
    RatingBar.builder(
      initialRating: _averageRating, // Set the initial rating to the fetched average rating
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Color.fromARGB(255, 255, 191, 0),
      ),
      onRatingUpdate: (value) {
        // No functionality for updating the rating since it’s static
      },
      ignoreGestures: true, // Make the rating bar uneditable (static)
    ),
  ],
),


            const SizedBox(height: 16),
            ElevatedButton.icon(
onPressed: () async {

  
  // Ensure setsenderUser is completed
  await setsenderUser();
  
                if (senderuser == 'Guest') {
                  print("User is a guest");
                  _showLoginAlert(context);
                  return;
                }
  final String currentUserName = senderuser; // Now senderuser will have the correct value
  print("this is from the button $currentUserName");
  
  final String otherUserName = widget.userName; // Username of the displayed user
  
  // Fetch or create a chat room
  String chatRoomId = await getOrCreateChatRoom(currentUserName, otherUserName);
  
  // Navigate to the ChatScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatRoomId: chatRoomId,
        currentUserName: currentUserName,
        otherUserName: otherUserName,
      ),
    ),
  );
},


              icon: const Icon(Icons.message, color: Colors.white),
              label: const Text(
                'Message',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: Color.fromARGB(255, 254, 111, 103),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft, // Aligns to the left
                child: Text(
                  "Items:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sorting and filtering options
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: _selectedSort,
                          items: [
                            'Newest to Oldest',
                            'Oldest to Newest',
                            'Lowest to Highest Price',
                            'Highest to Lowest Price',
                            'A-Z',
                            'New',
                            'Used',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSort = value;
                                _applyFilters();
                              });
                            }
                          },
                          isExpanded: true,
                          underline: Container(),
                          borderRadius: BorderRadius.circular(8),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showPriceRangeDialog(context),
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _userItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredItems.isEmpty
                          ? _userItems.length
                          : _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems.isEmpty
                            ? _userItems[index]
                            : _filteredItems[index];
                        final category = item['category']; // Get the category

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Image.asset(
                              _getCategoryIcon(
                                  category), // Display the icon based on the category
                              width: 40, // Icon width
                              height: 40, // Icon height
                            ),
                            title: Text(item['title']),
                            trailing: Text(
                              '₪${item['price']}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final itemId = item['_id']; // Get the item ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemPage(itemId: itemId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
