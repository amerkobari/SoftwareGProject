import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File type
import 'package:flutter/services.dart';

class AddNewShopPage extends StatefulWidget {
  const AddNewShopPage({Key? key}) : super(key: key);

  @override
  _AddNewShopPageState createState() => _AddNewShopPageState();
}

class _AddNewShopPageState extends State<AddNewShopPage> {
  final _formKey = GlobalKey<FormState>();  // Form key for validation
  bool _acceptTerms = false;
  String city = ''; // Variable to store selected city
  String shopName = '';
  String description = '';
  String shopAddress = '';
  String email = '';
  String phoneNumber = '';
  File? _logoImage;  // To store the selected logo image
  String cardHolderName = '';
  String cardNumber = '';
  String expirationDate = '';
  String cvv = '';

  final ImagePicker _picker = ImagePicker();  // Initialize ImagePicker

// List of Palestinian cities
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
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);  // Picking image from gallery
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Shop',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,  // Assign the form key
            child: Column(
              children: [
                // Shop Name
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the shop name';
                    }
                    return null;
                  },
                  onChanged: (value) => shopName = value,
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onChanged: (value) => description = value,
                ),

                const SizedBox(height: 16),

                // City Selection (Dropdown)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(),
                  ),
                  value: city.isEmpty ? null : city,
                  onChanged: (newValue) {
                    setState(() {
                      city = newValue!;
                    });
                  },
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Shop Address
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Shop Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the shop address';
                    }
                    return null;
                  },
                  onChanged: (value) => shopAddress = value,
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    // Email regex validation
                    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    RegExp regExp = RegExp(emailPattern);
                    if (!regExp.hasMatch(value)) {
                      return 'Please enter a valid email (e.g., user@example.com)';
                    }
                    return null;
                  },
                  onChanged: (value) => email = value,
                ),
                const SizedBox(height: 16),
                
                // Phone Number
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number, // Allows only numeric input
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allows digits (0-9)
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    // Ensure the phone number only contains digits
                    String phonePattern = r'^[0-9]+$';
                    RegExp regExp = RegExp(phonePattern);
                    if (!regExp.hasMatch(value)) {
                      return 'Phone number must contain only numbers';
                    }
                    return null;
                  },
                  onChanged: (value) => phoneNumber = value,
                ),
                
               
                const SizedBox(height: 16),
                
                // Shop Logo Picker (Image)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _logoImage == null
                        ? const Center(child: Text('Tap to pick a logo'))
                        : Image.file(
                            _logoImage!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Payment Method Section (Credit/Debit Card)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Cardholder's Name
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the cardholder name';
                          }
                          return null;
                        },
                        onChanged: (value) => cardHolderName = value,
                      ),
                      const SizedBox(height: 16),
                      
                      // Card Number
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only allows digits (0-9)
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the card number';
                          }
                          // Card number validation (basic length check)
                          if (value.length < 16) {
                            return 'Card number must be 16 digits';
                          }
                          return null;
                        },
                        onChanged: (value) => cardNumber = value,
                      ),
                      const SizedBox(height: 16),
                      
                      // Expiration Date
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiration Date (MM/YY)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')) // Only allows digits and "/"
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the expiration date';
                          }
                          // Expiration date basic validation
                          String expPattern = r'^(0[1-9]|1[0-2])\/[0-9]{2}$';  // MM/YY format
                          RegExp regExp = RegExp(expPattern);
                          if (!regExp.hasMatch(value)) {
                            return 'Enter a valid expiration date (MM/YY)';
                          }
                          return null;
                        },
                        onChanged: (value) => expirationDate = value,
                      ),
                      const SizedBox(height: 16),
                      
                      // CVV
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only allows digits (0-9)
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the CVV';
                          }
                          if (value.length != 3) {
                            return 'CVV must be 3 digits';
                          }
                          return null;
                        },
                        onChanged: (value) => cvv = value,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                
                // Monthly Subscription Text
                Text(
                  'Monthly Subscription: ₪100',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Submit Button
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Submit the form data (store the details)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing payment')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue, // Solid blue button
                    ),
                    child: const Text(
                      ' Submit Shop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
