import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert'; // Add this import

import 'package:untitled/controllers/authController.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  

  const CheckoutPage({super.key, required this.cartItems, required this.totalPrice});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
    final authController = AuthController(); // Define the authController

  final String baseUrl = "http://10.0.2.2:3000"; // Replace with your backend URL
  double deliveryFee = 10.0; // Placeholder delivery fee
  double totalAmount = 0.0;
  String? selectedCity;
  bool paymentOnDelivery = false;
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
   bool isFirstOrder = false;

  String promoCode = "";
  bool promoApplied = false;

  

  @override
  void initState() {
    super.initState();
    totalAmount = widget.totalPrice + deliveryFee;
  }

Future<void> checkFirstOrder() async {
  if (email != null && email!.isNotEmpty) {
    try {
      //  final url = Uri.parse('$baseUrl/api/auth/send-new-shop-email');
      final url = Uri.parse('$baseUrl/api/auth/check-first-order/$email');
      final response = await http.get(url);
      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          isFirstOrder = result['isFirstOrder'];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking first order: $error')),
      );
    }
  }
}

Future<void> applyPromoCode() async {
  if (promoCode == 'FIRSTORDER' && !promoApplied) {
    // Check first order status before applying promo code
    await checkFirstOrder();

    if (isFirstOrder) {
      setState(() {
        totalAmount *= 0.8; // Apply 20% discount
        promoApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo code applied!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not eligible for the promo code.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid promo code or already applied.')),
    );
  }
}


Future<void> setitemSold() async {
  try {
    for (final item in widget.cartItems) {
      final url = Uri.parse('$baseUrl/api/auth/update-item-sold/${item['_id']}');
      final response = await http.put(url);
    }
    
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error setting item as sold: $error')),
    );
  } 
}

  Future<void> sendOrderEmail() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      final orderDetails = {
  'firstName': firstName,
  'lastName': lastName,
  'email': email,
  'items': widget.cartItems.map((item) => {
    'name': item['title'],
    // 'quantity': item['quantity'],
    'price': item['price'],
    'imageUrl': item['images'],
    'imageCid': 'product-${item['_id']}', // Generate unique CID
  }).toList(),
  'total': totalAmount,
  'deliveryAddress': location,
  'city': selectedCity,
  'phoneNumber': phoneNumber,
};

      final result = await authController.ordercompletionmail(orderDetails);
      // print("ORDEER DETIAAALSSSS :$orderDetails");
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully')),
        );
        // Navigate to home page after successful order
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: ${result['message']}')),
        );
      }
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
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
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
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'First Name'),
                      onChanged: (value) => firstName = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      onChanged: (value) => lastName = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => email = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        // Check for valid email format using regex
                        else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return 'Enter a valid email (e.g., user@example.com)';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '05xxxxxxxx', // Hint text for phone number format
                        hintStyle: const TextStyle(
                  color: Color(0xffDDDADA),
                ),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Ensures only digits are entered
                      ],
                      onChanged: (value) => phoneNumber = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        } else if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
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
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      onChanged: (value) => location = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Display cart items
              Padding(
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
                          title: Text(item['title'] ?? 'Untitled'),
                          trailing: Text(
                            "₪${item['price'] ?? '0.00'}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Subtotal: ₪${widget.totalPrice}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Delivery Fee: ₪$deliveryFee',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(),
                    Text(
                      'Total: ₪$totalAmount',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                     const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Promo Code'),
                      onChanged: (value) => promoCode = value,
                    //   validator: (value) => value?.isEmpty ?? true
                    //       ? 'Enter a promo code or leave it blank'
                    //       : null,
                    ),
                    ElevatedButton(
                      onPressed: applyPromoCode,
                      child: const Text('Apply Promo Code'),
                    ),
                  ],
           
                   
                  
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox for "Payment on Delivery"
              CheckboxListTile(
                title: const Text('I agree that payment will be made on delivery'),
                value: paymentOnDelivery,
                onChanged: (value) {
                  setState(() {
                    paymentOnDelivery = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!paymentOnDelivery) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You must agree to payment on delivery')),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      // Call the function to send email
                      sendOrderEmail();
                      setitemSold();
                    } else {
                      // If validation fails, show error messages
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
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
}
