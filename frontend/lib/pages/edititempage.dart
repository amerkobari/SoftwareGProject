import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/controllers/authController.dart';

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
  final ImagePicker _picker = ImagePicker();
  String title = '';
  String description = '';
  String price = '';
  String? condition;
  // String? location;
  String? selectedCity;
  List<File> images = []; // Holds selected images
  final List<XFile> _imageFiles = []; // Holds image files
  List<dynamic> imagesFromDatabase = [];

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
      selectedCity = itemDetails['location'];
      imagesFromDatabase = itemDetails['imageUrls'] as List<dynamic> ?? []; // Add this line to fetch image URLs
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

  try {
    final response = await _authController.updateItem(
      widget.itemId,
      title,
      description,
      price,
      condition!,
      selectedCity!,
      images, 
    );
    print(response);
    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item updated successfully!')),
      );
      Navigator.pop(context);
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
                        DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'City'),
                      value: selectedCity,
                      items: cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                                    const SizedBox(height: 10),
                                    Column(
  children: [
    // New Box for Images
    imagesFromDatabase.isNotEmpty
        ? Container(
            width: MediaQuery.of(context).size.width * 0.92,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
  child: Column(
    children: [
      // Box for Database Images
      const SizedBox(height: 10),
      SizedBox(
        height: 150, // Explicit height constraint
        child: imagesFromDatabase.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width * 0.92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // One row
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: imagesFromDatabase.length,
                  itemBuilder: (context, index) {
  final imageUrl = imagesFromDatabase[index];

  // Debugging: Log image URL type
  print("Image URL: $imageUrl");

  return GestureDetector(
    onTap: () async {
      try {
        if (imageUrl.startsWith('data:')) {
          // Extract base64 data
          final base64Image = imageUrl.split(',')[1];
          print("Base64 Image Detected");

          // Decode base64 and create a temporary file
          final decodedBytes = base64Decode(base64Image);
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/temp_image_$index.png');
          await tempFile.writeAsBytes(decodedBytes);

          // Add to images list
          setState(() {
            images.add(tempFile);
          });
        } else {
          // Regular URL case
          print("Network Image Detected");
          setState(() {
            images.add(File(imageUrl));
          });
        }
      } catch (e) {
        print("Error handling image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error handling image: $e')),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl.startsWith('data:')
          ? Image.memory(
              base64Decode(imageUrl.split(',')[1]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text('Error loading image'),
                );
              },
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text('Error loading image'),
                );
              },
            ),
  ),
);
                  },
                ),
              )
            : const Center(
                child: Text(
                  'No images available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
      ),

      const SizedBox(height: 10),

      // Existing Content
      Container(
        width: MediaQuery.of(context).size.width * 0.92,
        // Existing widget configuration
      ),
    ],
  ),
),

          )
        : const Center(
            child: Text('No images available', style: TextStyle(color: Colors.grey)),
          ),

    const SizedBox(height: 10),

    // Existing Widget
    Container(
      width: MediaQuery.of(context).size.width * 0.92,
      // Existing widget configuration
    ),
  ],
),
                const SizedBox(height: 10),
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
                        icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                        label: const Text('Pick Images', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      images.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        icon: const Icon(Icons.close, color: Colors.red),
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
  // Function to pick images
  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      images = pickedFiles.map((file) => File(file.path)).toList();
    });
    }



  // Method to remove an image
  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  File base64StringToFile(String base64Str, String fileName) {
    final bytes = base64Decode(base64Str);
    final file = File(fileName);
    file.writeAsBytesSync(bytes);  // Write the bytes to the file
    return file;
  }

}
