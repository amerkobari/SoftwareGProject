import 'package:flutter/material.dart';
import 'package:untitled/pages/itempage.dart';
import 'package:untitled/controllers/authController.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({required this.query, super.key});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final AuthController authController = AuthController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  String _selectedSort = 'Newest to Oldest';
  RangeValues _priceRange = const RangeValues(0, 10000); // Default price range

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    try {
      final results = await authController.fetchSearchItems(widget.query);
      setState(() {
        _searchResults = results;
        _filteredResults = List.from(_searchResults);
        _applyFilters();
      });
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredResults = List.from(_searchResults);

      // Apply sorting
      if (_selectedSort == 'Lowest to Highest Price') {
        _filteredResults.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (_selectedSort == 'Highest to Lowest Price') {
        _filteredResults.sort((a, b) => b['price'].compareTo(a['price']));
      } else if (_selectedSort == 'A-Z') {
        _filteredResults.sort((a, b) => a['title'].compareTo(b['title']));
      } else if (_selectedSort == 'Newest to Oldest') {
        _filteredResults.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));
      } else if (_selectedSort == 'Oldest to Newest') {
        _filteredResults.sort((a, b) => DateTime.parse(a['createdAt'])
            .compareTo(DateTime.parse(b['createdAt'])));
      }

      // Apply condition filter
      if (_selectedSort == 'New') {
        _filteredResults = _filteredResults
            .where((item) => item['condition'] == 'New')
            .toList();
      } else if (_selectedSort == 'Used') {
        _filteredResults = _filteredResults
            .where((item) => item['condition'] == 'Used')
            .toList();
      }

      // Apply price range filter
      _filteredResults = _filteredResults
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
    return categoryIcons[category] ?? 'assets/icons/$categoryIcons.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Results',
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
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final item = _filteredResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: ListTile(
                  leading: Image.asset(
                    _getCategoryIcon(item['category']), // Dynamically get icon based on category
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