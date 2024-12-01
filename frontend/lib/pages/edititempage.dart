import 'dart:io';

import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
import 'dart:convert';

class EditItemPage extends StatefulWidget {
  final String itemId; // Pass only item ID instead of the entire item data

  const EditItemPage({super.key, required this.itemId});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final AuthController _authController = AuthController();
  Map<String, dynamic>? _itemData; // Holds item data fetched from the backend
  bool _isLoading = true; // Track loading state

  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String price = '';
  String? condition;
  String? location;
  List<File> images = [];
  
  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    try {
      final itemDetails = await _authController.getItemById(widget.itemId);
      setState(() {
        _itemData = itemDetails;
        title = itemDetails['title'];
        description = itemDetails['description'];
        price = itemDetails['price'].toString();
        condition = itemDetails['condition'];
        location = itemDetails['location'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load item details: $e')),
      );
    }
  }

  // Function to handle updating the item
  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();

    // Assuming you have an update API endpoint
    try {
      final response = await _authController.updateItem(
        widget.itemId,  // Item ID to update
        title,
        description,
        price,
        condition!,
        location!,
        images,  // Handle image uploading or URL if applicable
      );
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item updated successfully!')),
        );
        Navigator.pop(context); // Go back after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: const Text('Edit Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itemData == null
              ? const Center(child: Text('Item not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: title,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          onSaved: (value) => title = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          onSaved: (value) => description = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a description' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: price,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                          ),
                          onSaved: (value) => price = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a price' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: condition,
                          items: const [
                            DropdownMenuItem(
                              value: 'New',
                              child: Text('New'),
                            ),
                            DropdownMenuItem(
                              value: 'Used',
                              child: Text('Used'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Condition',
                          ),
                          onChanged: (value) {
                            setState(() {
                              condition = value;
                            });
                          },
                          onSaved: (value) => condition = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: location,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                          ),
                          onSaved: (value) => location = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a location' : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Handle image picking if needed
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Pick Images'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _updateItem,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Update Item',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Future<Map<String, dynamic>> updateItem(String itemId, Map<String, dynamic> updatedItemData) async {
//   final url = Uri.parse('$baseUrl/api/auth/update-item/$itemId'); // Adjust this URL according to your backend

//   try {
//     final response = await http.put(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         // You can also add an Authorization header here if needed
//       },
//       body: jsonEncode(updatedItemData),
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       return {'success': true, 'message': responseData['message'] ?? 'Item updated successfully'};
//     } else {
//       final responseData = jsonDecode(response.body);
//       return {'success': false, 'message': responseData['error'] ?? 'Failed to update item'};
//     }
//   } catch (e) {
//     print('Error occurred while updating item: $e');
//     return {'success': false, 'message': 'Unable to connect to the server.'};
//   }
// }
