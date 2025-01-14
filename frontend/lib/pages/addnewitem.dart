import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemPage extends StatefulWidget {
  final String? shopId; // Optional shopId parameter

  const AddItemPage({super.key, this.shopId});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String price = '';
  String? category;
  String? condition;
  String? location;
  List<File> images = [];
  bool acceptTerms = false;
  bool acceptTermsError = true;

  final ImagePicker _picker = ImagePicker();

  // Options for dropdowns
  final List<String> categories = [
    'CPU',
    'GPU',
    'RAM',
    'Hard Disk',
    'Motherboard',
    'Case',
    'Monitors',
    'Accessories'
  ];
  final List<String> conditions = ['New', 'Used'];
  final List<String> cities = [
    'Jerusalem',
    'Gaza',
    'Ramallah',
    'Hebron',
    'Nablus',
    'Bethlehem',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Jericho',
    'Salfit',
    'Tubas',
    'Rafah',
    'Khan Yunis',
    'Deir al-Balah'
  ];

  double getDynamicFeePercentage(double price) {
    if (price >= 1000) {
      return 8.0;
    } else if (price >= 800) {
      return 7.0;
    } else if (price >= 300) {
      return 5.0;
    } else {
      return 3.0;
    }
  }

  // Function to pick images
  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      images = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  // Function to handle price change dynamically
  void onPriceChanged(String value) {
    setState(() {
      price = value;
    });
  }

  // Function to send data to the API

  Future<void> submitItem() async {
    if (acceptTermsError) {
      // Show error for terms acceptance
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please accept the terms.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (images.isEmpty) {
      // Show error for missing images
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please upload at least one image.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    String token = await _getToken();
    if (token.isEmpty) {
      print("Token is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found, please login again.')),
      );
      return;
    }

    try {
      // Decode token to get userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['id'];
      String username = decodedToken['username'];

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:3000/api/auth/add-item'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Include common fields
      request.fields['userId'] = userId;
      request.fields['username'] = username;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['price'] = price;
      request.fields['category'] = category!;
      request.fields['condition'] = condition!;
      request.fields['location'] = location!;

      // Include shopId if available
      if (widget.shopId != null) {
        request.fields['shopId'] = widget.shopId!;
      }

      // Add images
      for (var image in images) {
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));
      }
      var response = await request.send();
      if (response.statusCode == 201) {
        // Success
        final resData = await response.stream.bytesToString();
        final resJson = json.decode(resData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item.')),
        );
        print(await response.stream.bytesToString());
      }
    } catch (e) {
      print("Error decoding token: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid token, please login again.')),
      );
    }
  }

// Helper function to get the token
  Future<String> _getToken() async {
    // Fetch the token from shared preferences, secure storage, or any method you are using to store the token
    // Example:
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
    // For this example, you can just return a dummy token or whatever method you use to store the token.
    return 'your_token_here'; // Replace with the actual token fetching logic
  }

  @override
  Widget build(BuildContext context) {
    double parsedPrice = 0.0;
    if (price.isNotEmpty) {
      parsedPrice = double.tryParse(price) ?? 0.0;
    }

    double feePercentage = getDynamicFeePercentage(parsedPrice);
    double feeAmount = (parsedPrice * feePercentage) / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Item',
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = value!;
                  },
                  onChanged: onPriceChanged, // Update price dynamically
                ),

                const SizedBox(height: 30), // Increased space before 'Category'
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: categories.map((cat) {
                    return ChoiceChip(
                      label: Text(cat),
                      selected: category == cat,
                      selectedColor: Color.fromARGB(255, 254, 111,
                          103), // Set background color to blue when selected
                      backgroundColor: Color.fromARGB(255, 254, 111, 103)
                          .withOpacity(
                              0.1), // Set background color to gray when not selected
                      onSelected: (selected) {
                        setState(() {
                          category = selected ? cat : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                if (category == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a category',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                // Similar code for 'Condition'
                const SizedBox(height: 20),
                const Text(
                  'Condition',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: conditions.map((cond) {
                    return ChoiceChip(
                      label: Text(cond),
                      selected: condition == cond,
                      selectedColor: Color.fromARGB(255, 254, 111,
                          103), // Set background color to blue when selected
                      backgroundColor: Color.fromARGB(255, 254, 111, 103)
                          .withOpacity(
                              0.1), // Set background color to gray when not selected
                      onSelected: (selected) {
                        setState(() {
                          condition = selected ? cond : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                if (condition == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a condition',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'City'),
                  value: location,
                  items: cities.map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: Text(loc),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      location = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Images',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.92, // Make the box 90% of the screen width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Shadow position
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            color: Colors.white),
                        label: const Text('Pick Images',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 254, 111, 103),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      images.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey),
                                        image: DecorationImage(
                                          image: FileImage(images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'No images selected',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity
                      .leading, // Moves checkbox to the left of the text
                  title: Text(
                    '$feePercentage% - ₪${feeAmount.toStringAsFixed(2)} of the sale will be charged as a fee',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  value: acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptTerms = value!;
                      acceptTermsError = !acceptTerms; // Reset error if checked
                    });
                  },
                  activeColor: Color.fromARGB(
                      255, 254, 111, 103), // Change the tick color to green
                  checkColor: Colors
                      .white, // Change the color of the checkmark to white
                ),
                if (acceptTermsError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You must accept the fee to proceed',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 30.0), // Add bottom padding here
                  child: Center(
                    child: ElevatedButton(
                      onPressed: submitItem,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color.fromARGB(
                            255, 254, 111, 103), // Solid blue button
                      ),
                      child: const Text(
                        'Submit Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
