import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddItemPage extends StatefulWidget {
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

  final ImagePicker _picker = ImagePicker();

  // Options for dropdowns
  final List<String> categories = ['CPU', 'GPU', 'RAM', 'Hard Disk', 'Motherboard', 'Case', 'Monitors', 'Accessories'];
  final List<String> conditions = ['New', 'Used'];
  final List<String> cites = [
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
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
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
        SnackBar(content: Text('Item added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item. Please try again.')),
      );
      print(await response.stream.bytesToString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
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
                  decoration: InputDecoration(labelText: 'Description'),
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
                  decoration: InputDecoration(labelText: 'Price'),
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Category'),
                  value: category,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Condition'),
                  value: condition,
                  items: conditions.map((cond) {
                    return DropdownMenuItem(
                      value: cond,
                      child: Text(cond),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      condition = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a condition';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'City'),
                  value: location,
                  items: cites.map((loc) {
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickImages,
                  child: Text('Pick Images'),
                ),
                SizedBox(height: 10),
                images.isNotEmpty
                    ? Wrap(
                        spacing: 10,
                        children: images
                            .map((img) => Image.file(
                                  img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      )
                    : Text('No images selected'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitItem,
                  child: Text('Submit Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
