import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';

class ShopPage extends StatefulWidget {
  final String shopId;

  const ShopPage({super.key, required this.shopId});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _shopData;
  List<Map<String, dynamic>> _shopItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String _selectedSort = 'Newest to Oldest';  // Default sort option
  RangeValues _priceRange = const RangeValues(0, 10000); // Default price range

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    try {
      // Fetch shop details
      final shopDetails = await _authController.getShopById(widget.shopId);
      setState(() {
        _shopData = shopDetails['shop'];
      });

      // Fetch items of the shop
      final items = await _authController.fetchItemsShop(widget.shopId);
      setState(() {
        _shopItems = items;
        _filteredItems = List.from(_shopItems);  // Initialize filtered items
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shop details: $e')),
      );
    }
  }

  // Apply filters and sorting to items
  void _applyFilters() {
    setState(() {
      _filteredItems = List.from(_shopItems); // Reset the filtered list

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
        _filteredItems = _filteredItems.where((item) => item['condition'] == 'New').toList();
      } else if (_selectedSort == 'Used') {
        _filteredItems = _filteredItems.where((item) => item['condition'] == 'Used').toList();
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
                final double? startPrice = double.tryParse(startPriceController.text);
                final double? endPrice = double.tryParse(endPriceController.text);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 254, 111,103),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: Text(_shopData?['shopName'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shopData == null
              ? const Center(child: Text('Shop not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop details
                      SizedBox(
                        height: 200,
                        child: _shopData?['logoUrl'] == null
                            ? const Center(child: Text('No logo available'))
                            : Builder(
                                builder: (context) {
                                  final logoUrl = _shopData!['logoUrl'];
                                  if (logoUrl is String && logoUrl.startsWith('data:')) {
                                    return ClipOval(
                                      child: Image.memory(
                                        Base64Decoder().convert(logoUrl.split(',')[1]),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else if (logoUrl is String) {
                                    return ClipOval(
                                      child: Image.network(
                                        logoUrl,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(child: Icon(Icons.error, size: 50)),
                                      ),
                                    );
                                  } else {
                                    return const Center(child: Text('Invalid logo format'));
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shopData!['shopName'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      
                      // const SizedBox(height: 8),
                      // Text(
                      //   "Location: ${_shopData!['city']}, ${_shopData!['shopAddress']}",
                      //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                      // ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   "Email: ${_shopData!['email']}",
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   "Phone: ${_shopData!['phoneNumber']}",
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.mail,
                              color: Color.fromARGB(255, 254, 111, 103),
                              size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _shopData!['email'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              color: Color.fromARGB(255, 254, 111, 103),
                              size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _shopData!['phoneNumber'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 254, 111, 103),
                              size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${_shopData!['city']}, ${_shopData!['shopAddress']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 16),
                      // const Text(
                      //   "Description:",
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   _shopData!['description'] ?? 'No description provided',
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      const SizedBox(height: 16),
                      Text(
                        "Items:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Sorting and filtering options
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                      
                       const SizedBox(height: 8),
                      // Items list
                      _shopItems.isEmpty
                          ? const Text('No items available')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _shopItems.length,
                              itemBuilder: (context, index) {
                                final item = _shopItems[index];
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(item['title']),
                                    subtitle: Text("Price: \$${item['price']}"),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () async {
                    // Navigate to ItemPage with API call
                    final itemId = item['_id']; // Assuming each item has an 'id'
                    //print the item id
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemPage(itemId: itemId),
                      ),
                    );
                  },
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}
// class _ShopPageState extends State<ShopPage> {
//   final AuthController _authController = AuthController();
//   Map<String, dynamic>? _shopData;
//   List<Map<String, dynamic>> _shopItems = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchShopDetails();
//   }

//   Future<void> _fetchShopDetails() async {
//     try {
//       // Fetch shop details
//       final shopDetails = await _authController.getShopById(widget.shopId);
//       setState(() {
//         _shopData = shopDetails['shop'];
//       });

//       // Fetch items of the shop
//       final items = await _authController.fetchItemsShop(widget.shopId);
//       setState(() {
//         _shopItems = items;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load shop details: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
//         title: Text(_shopData?['shopName'] ?? 'Loading...'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _shopData == null
//               ? const Center(child: Text('Shop not found'))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Shop details
//                      SizedBox(
//   height: 200,
//   child: _shopData?['logoUrl'] == null
//       ? const Center(child: Text('No logo available'))
//       : Builder(
//           builder: (context) {
//             final logoUrl = _shopData!['logoUrl'];
//             // Check if the logo is base64-encoded
//             if (logoUrl is String && logoUrl.startsWith('data:')) {
//               return ClipOval(
//                 child: Image.memory(
//                   Base64Decoder().convert(logoUrl.split(',')[1]),
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               );
//             } else if (logoUrl is String) {
//               // If logo is a URL
//               return ClipOval(
//                 child: Image.network(
//                   logoUrl,
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) =>
//                       const Center(child: Icon(Icons.error, size: 50)),
//                 ),
//               );
//             } else {
//               return const Center(child: Text('Invalid logo format'));
//             }
//           },
//         ),
// ),

                      // const SizedBox(height: 16),
                      // Text(
                      //   _shopData!['shopName'],
                      //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   "Location: ${_shopData!['city']}, ${_shopData!['shopAddress']}",
                      //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                      // ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   "Email: ${_shopData!['email']}",
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   "Phone: ${_shopData!['phoneNumber']}",
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // const SizedBox(height: 16),
                      // const Text(
                      //   "Description:",
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   _shopData!['description'] ?? 'No description provided',
                      //   style: const TextStyle(fontSize: 16),
                      // ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         "Items:",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       // Items list
//                       _shopItems.isEmpty
//                           ? const Text('No items available')
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: _shopItems.length,
//                               itemBuilder: (context, index) {
//                                 final item = _shopItems[index];
//                                 return Card(
//                                   elevation: 2,
//                                   child: ListTile(
//                                     title: Text(item['title']),
//                                     subtitle: Text("Price: \$${item['price']}"),
//                                     trailing: const Icon(Icons.arrow_forward),
//                                     onTap: () async {
//                     // Navigate to ItemPage with API call
//                     final itemId = item['_id']; // Assuming each item has an 'id'
//                     //print the item id
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ItemPage(itemId: itemId),
//                       ),
//                     );
//                   },
//                                   ),
//                                 );
//                               },
//                             ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }