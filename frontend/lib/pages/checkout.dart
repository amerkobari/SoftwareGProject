import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/itempage.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final authController = AuthController(); // AuthController for API integration
  final String baseUrl = "http://10.0.2.2:3000"; // Replace with your backend URL

  double deliveryFee = 0.0; // Fixed delivery fee
  double totalAmount = 0.0;
  String? selectedCity;
  bool paymentOnDelivery = false;

  // List of available cities
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

  // Fields for user information
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? location;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.totalPrice + deliveryFee; // Calculate the total amount
  }

 Future<void> calculateDeliveryFees(String selectedCity, String location) async {
  double totalDeliveryFee = 0.0;
  try {
    if (selectedCity != null && location != null) {
      for (var item in widget.cartItems) {
        // Fetch the distance using authController.getDistance
        final result = await authController.getDistance(
          '$selectedCity, Palestine',
          '${item['location']}, Palestine',
        );

        if (result['success']) {
          double distance = double.parse(result['distance']);
          print('Distance between $selectedCity and ${item['location']}: $distance km');

          // Calculate fee based on distance
          double fee;
          if (distance < 10) {
            fee = 10.0;
          } else if (distance >= 10 && distance < 20) {
            fee = 15.0;
          } else if (distance >= 20 && distance < 50) {
            fee = 25.0;
          } else {
            fee = 50.0; // For distances 50km or more
          }

          totalDeliveryFee += fee;
        } else {
          // Handle error when fetching distance
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error calculating delivery fees for ${item['title']}: ${result['message']}',
              ),
            ),
          );
          return; // Return the current total fees in case of an error
        }
      }
    }
  } catch (error) {
    // Handle unexpected errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }

setState(() {
    deliveryFee = totalDeliveryFee;
    totalAmount = widget.totalPrice + deliveryFee;
});
  return;
}



  // Function to handle order email submission
  Future<void> sendOrderEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final orderDetails = {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'items': widget.cartItems.map((item) => {
                'name': item['title'],
                'price': item['price'],
                'imageUrl': item['images'],
                'imageCid': 'product-${item['_id']}', // Unique CID
              }).toList(),
          'total': totalAmount,
          'deliveryAddress': location,
          'city': selectedCity,
          'phoneNumber': phoneNumber,
        };

        final result = await authController.ordercompletionmail(orderDetails);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully')),
          );
          Navigator.pop(context); // Navigate back on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error placing order: ${result['message']}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Information
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Delivery Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'First Name',
                      onChanged: (value) => firstName = value,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'First name is required' : null,
                    ),
                    _buildTextField(
                      label: 'Last Name',
                      onChanged: (value) => lastName = value,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Last name is required' : null,
                    ),
                    _buildTextField(
                      label: 'Email',
                      onChanged: (value) => email = value,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Phone Number',
                      onChanged: (value) => phoneNumber = value,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                          return 'Enter a valid 10-digit phone number starting with 05';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'City'),
  value: selectedCity,
  items: cities.map((city) {
    return DropdownMenuItem(
      value: city,
      child: Text(city),
    );
  }).toList(),
  onChanged: (value) async {
    setState(() {
      selectedCity = value;
      totalAmount = widget.totalPrice; 
      calculateDeliveryFees(selectedCity!, widget.cartItems[0]['location'] ?? '');
    });
    
  },
  validator: (value) =>
      value?.isEmpty ?? true ? 'Please select a city' : null,
),

                    _buildTextField(
                      label: 'Location',
                      onChanged: (value) => location = value,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Location is required' : null,
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Cart Items and Summary
              _buildCartSummary(),

              // Payment Agreement Checkbox
              CheckboxListTile(
                title: const Text('I agree that payment will be made on delivery'),
                value: paymentOnDelivery,
                onChanged: (value) =>
                    setState(() => paymentOnDelivery = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),

              // Proceed Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!paymentOnDelivery) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('You must agree to payment on delivery')),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      sendOrderEmail();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Proceed',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for reusable text fields
  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  // Cart Summary
  Widget _buildCartSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In Your Bag',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              return ListTile(
                title: Text(item['title'] ?? 'Untitled'), subtitle: Text(item['location'] ?? 'No location'),
                trailing: Text(
                  "₪${item['price'] ?? '0.00'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text('Subtotal: ₪${widget.totalPrice}', style: const TextStyle(fontSize: 16)),
          Text('Delivery Fee: ₪$deliveryFee', style: const TextStyle(fontSize: 16)),
          Text(
            'Total: ₪$totalAmount',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
