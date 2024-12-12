import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserItems();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add right padding
            child: IconButton(
              icon: const Icon(
                Icons.star_rate, // Changed to a 'Rate' icon
                color: Colors.white, // Icon color set to white
              ),
              onPressed: () {
                // Show a dialog to collect star rating
                showDialog(
                  context: context,
                  builder: (context) {
                    double rating = 0; // Initialize rating
                    return AlertDialog(
                      title: const Text("Rate Seller"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Please rate the Seller:"),
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
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
                            // Save the rating and close the dialog
                            print("Rating submitted: $rating");
                            Navigator.of(context).pop();
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Rate',
            ),
          ),
        ],
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
            const SizedBox(height: 16),
            Column(
              children: [
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: 5, // Example initial rating
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
                    print(
                        "Updated Rating: $value"); // Handle rating update here
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add functionality for the Message button here
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
