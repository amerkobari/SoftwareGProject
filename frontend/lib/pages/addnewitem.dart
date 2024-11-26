import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

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
  final List<String> categories = ['CPU', 'GPU', 'RAM', 'Hard Disk', 'Motherboard', 'Case', 'Monitors', 'Accessories'];
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

  // Function to pick images
  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Function to send data to the API
  Future<void> submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    String userId = "64a0d7a9d43e4c321be52b9c";

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/api/auth/add-item'),
    );

    request.fields['userId'] = userId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['category'] = category!;
    request.fields['condition'] = condition!;
    request.fields['location'] = location!;

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final resJson = json.decode(resData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add item. Please try again.')),
      );
      print(await response.stream.bytesToString());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = value!;
                  },
                ),
                
                SizedBox(height: 30), // Increased space before 'Category'
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
                      selectedColor: Colors.blue,  // Set background color to blue when selected
                      backgroundColor: Colors.blue.withOpacity(0.1),  // Set background color to gray when not selected
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
                      selectedColor: Colors.blue,  // Set background color to blue when selected
                      backgroundColor: Colors.blue.withOpacity(0.1),  // Set background color to gray when not selected
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
                SizedBox(height: 20),
                Text(
                  'Images',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.92, // Make the box 90% of the screen width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),    
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                        label: Text('Pick Images', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 20),
                      images.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                        icon: Icon(Icons.close, color: Colors.red),
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'No images selected',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('5% of the sale will be charged as a fee'),
              value: acceptTerms,
              onChanged: (value) {
                setState(() {
                  acceptTerms = value!;
                  acceptTermsError = !acceptTerms; // Reset error if checked
                });
              },
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
                  padding: const EdgeInsets.only(bottom: 30.0), // Add bottom padding here
                  child: Center(
                    child: ElevatedButton(
                      onPressed: submitItem,
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
