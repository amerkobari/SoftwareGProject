import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  String city = '';
  String shopName = '';
  String description = '';
  String shopAddress = '';
  String email = '';
  String phoneNumber = '';
  File? logo;
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
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding shop: $error')),
        );
      }
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