import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/controllers/authController.dart'; // Adjust the path as necessary

class GPUPage extends StatefulWidget {
  const GPUPage({super.key});

  @override
  _GPUPageState createState() => _GPUPageState();
}

class _GPUPageState extends State<GPUPage> {
  final AuthController authController = AuthController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _selectedSort = 'Newest to Oldest';
  RangeValues _priceRange = const RangeValues(0, 10000); // Default price range

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await authController.fetchItems('GPU'); // Fetch GPU items
      setState(() {
        _items = items;
        _filteredItems = List.from(_items);
        _applyFilters();
      });
    } catch (e) {
      // Handle fetch errors
      print("Error fetching items: $e");
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = List.from(_items);

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

      // Apply condition filter
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
        title: const Text(
          'GPU',
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
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/icons/gpu.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    title: Text(item['title'] ?? 'No Title',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['description'] ?? 'No Description'),
                    trailing: Text(
                      '₪${item['price']?.toStringAsFixed(2) ?? 'N/A'}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final itemId = item['_id'];
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
          ),
        ],
      ),
    );
  }
}
