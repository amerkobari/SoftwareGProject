import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/controllers/authController.dart';

// Function to add a new shop
Future<void> addNewShop({
  required String city,
  required String shopName,
  String? description,
  required String shopAddress,
  required String email,
  required String phoneNumber,
  File? logo,
}) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/auth/add-shop');

  final request = http.MultipartRequest('POST', url);

  request.fields['city'] = city;
  request.fields['shopName'] = shopName;
  request.fields['description'] = description ?? '';
  request.fields['shopAddress'] = shopAddress;
  request.fields['email'] = email;
  request.fields['phoneNumber'] = phoneNumber;

 if (logo != null) {
    print('Logo path: ${logo.path}');
    request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
} else {
    print('Logo is null');
}

  print('Sending request with logo: ${logo?.path}');

  final response = await request.send();


  //print the response 
  print("THIS IS THE RESPONSE $response");
  if (response.statusCode == 201) {
    print('Shop added successfully!');
  } else {
    final responseBody = await response.stream.bytesToString();
    print('Failed to add shop: $responseBody');
  }
}

// UI to add a new shop
class AddNewShopPage extends StatefulWidget {
  const AddNewShopPage({super.key});

  @override
  _AddNewShopPageState createState() => _AddNewShopPageState();
}

class _AddNewShopPageState extends State<AddNewShopPage> {
  final _formKey = GlobalKey<FormState>();
  final authController = AuthController(); // Define the authController
  String city = '';
  String shopName = '';
  String description = '';
  String shopAddress = '';
  String email = '';
  String phoneNumber = '';
  File? logo;
  String cardHolderName = '';
  String cardNumber = '';
  String expirationDate = '';
  String cvv = '';
  final ImagePicker _picker = ImagePicker();

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
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        logo = File(pickedFile.path);
      });
    }
  }
Future<void> _submitShop() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await addNewShop(
          city: city,
          shopName: shopName,
          description: description,
          shopAddress: shopAddress,
          email: email,
          phoneNumber: phoneNumber,
          logo: logo,
        );

          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop added successfully!')),
        );

        final result = await authController.sendNewShopMail(email);
        if (result['success']) {
          _showSnackBar(context, result['message'], isError: false);
        } else {
          _showSnackBar(context, result['message']);
        }
      
        
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding shop: $error')),
        );
      }
    }
  }

 


  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
            key: _formKey,
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
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 16),
                // City
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
                    final emailPattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    if (!RegExp(emailPattern).hasMatch(value)) {
                      return 'Please enter a valid email';
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                  onChanged: (value) => phoneNumber = value,
                ),
                const SizedBox(height: 16),
                // Logo Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: logo == null
                        ? const Center(child: Text('Tap to pick a logo'))
                        : Image.file(
                            logo!,
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

                const SizedBox(height: 16),
                // Submit Button
                ElevatedButton(
                  onPressed: _submitShop,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Submit Shop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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