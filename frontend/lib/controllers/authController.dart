import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthController {
  final String baseUrl = "http://10.0.2.2:3000"; // Replace with your backend URL

  /// **Login Method**
Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/api/auth/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Check if the token exists
      final token = responseData['token'];
      if (token == null) {
        return {'success': false, 'message': 'Login failed: No token returned from server'};
      }

      // Decode the JWT to get the username and userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Validate the token payload
      if (!decodedToken.containsKey('username') || decodedToken['username'] == null) {
        return {'success': false, 'message': 'Login failed: Invalid token payload (username missing)'};
      }
      if (!decodedToken.containsKey('id') || decodedToken['id'] == null) {
        return {'success': false, 'message': 'Login failed: Invalid token payload (userId missing)'};
      }

      String username = decodedToken['username'];
      String userId = decodedToken['id'];

      // Store the token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return {
        'success': true,
        'message': responseData['message'],
        'token': token,     // Token returned from the backend
        'username': username, // Username extracted from the token
        'userId': userId,   // User ID extracted from the token
      };
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['error'] ?? 'Login failed'};
    }
  } catch (e) {
    print('Exception occurred during login: $e');
    return {'success': false, 'message': 'Unable to connect to the server.'};
  }
}


  /// **Register Method**
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String phoneNumber,
    String birthdate,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'birthdate': birthdate,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'message': responseData['message']};
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }

  /// **Send Reset Code**
  Future<Map<String, dynamic>> sendResetCode(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/send-reset-code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
      //i want to print the response data
      print(responseData);
      return {
        'success': true,
        'message': responseData['message'],
        'code': responseData['resetCode'], // Include verification code if needed
      };
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['error'] ?? 'Failed to send reset code'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }

 Future<Map<String, dynamic>> sendNewShopMail(String email) async {
  final url = Uri.parse('$baseUrl/api/auth/send-new-shop-email');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Printing the response data to debug
      print('Response Data: $responseData');
      return {
        'success': true,
        'message': responseData['message'],
      };
    } else {
      final responseData = jsonDecode(response.body);
      print('Error Response: $responseData');
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to send email',
      };
    }
  } catch (e) {
    print('Error occurred: $e');
    return {
      'success': false,
      'message': 'Unable to connect to the server.',
    };
  }
}


  /// **Reset Password**
  // ignore: non_constant_identifier_names
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword,String Verification) async {
    final url = Uri.parse('$baseUrl/api/auth/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': newPassword, 'code': Verification}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'message': responseData['message']};
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['error'] ?? 'Password reset failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }


    Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/send-verification-code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Print response data for debugging purposes
        print('Response Data: $responseData');
        return {
          'success': true,
          'message': responseData['message'],
          'code': responseData['verificationCode'], // Include verification code if returned
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send verification code',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }

   Future<List<Map<String, dynamic>>> fetchShops() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/get-allshops'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((shop) => shop as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (error) {
      throw Exception('Error fetching shops: $error');
    }
  }



    Future<List<Map<String, dynamic>>> fetchItems(String category) async {
    final url = Uri.parse('$baseUrl/api/auth/get-items-by-category/$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

Future<List<Map<String, dynamic>>> fetchItemsShop(String shopId) async {
    final url = Uri.parse('$baseUrl/api/auth/get-items-by-shop/$shopId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
   Future<Map<String, dynamic>> getItemById(String itemId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/get-item/$itemId'));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load item. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching item: $e');
    }
  }

  Future<Map<String, dynamic>> getShopById(String shopId) async {
  final url = Uri.parse('$baseUrl/api/auth/get-shop/$shopId'); // Replace with your actual endpoint

  try {
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      // Add an Authorization header if your API requires it
      // 'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      return {'success': true, 'shop': responseData};
    } else {
      final responseData = json.decode(response.body);
      return {
        'success': false,
        'message': responseData['error'] ?? 'Failed to fetch shop details',
      };
    }
  } catch (e) {
    print('Error fetching shop by ID: $e');
    return {'success': false, 'message': 'Unable to connect to the server.'};
  }
}

Future<Map<String, dynamic>> updateItem(String itemId, Map<String, dynamic> updatedItemData, String description, String price, String size, String color, List<File> images) async {
  final url = Uri.parse('$baseUrl/api/auth/update-item/$itemId'); // Adjust this URL according to your backend

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // You can also add an Authorization header here if needed
      },
      body: jsonEncode(updatedItemData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {'success': true, 'message': responseData['message'] ?? 'Item updated successfully'};
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['error'] ?? 'Failed to update item'};
    }
  } catch (e) {
    print('Error occurred while updating item: $e');
    return {'success': false, 'message': 'Unable to connect to the server.'};
  }
}


Future<Map<String, dynamic>> removeItem(String itemId) async {
  final url = Uri.parse('$baseUrl/api/auth/delete-item/$itemId'); // Adjust this URL according to your backend

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        // You can add an Authorization header here if your API requires it
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {'success': true, 'message': responseData['message'] ?? 'Item removed successfully'};
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['error'] ?? 'Failed to remove item'};
    }
  } catch (e) {
    print('Error occurred while removing item: $e');
    return {'success': false, 'message': 'Unable to connect to the server.'};
  }
}


Future<String?> fetchShopId() async {
  final url = Uri.parse('$baseUrl/api/auth/get-shop-id');

  // Retrieve the token from shared preferences or another storage
  String token = await _getToken();
  // Print the token for debugging purposes
  print('Token from auth controller: $token');
  
  if (token.isEmpty) {
    print("Token is empty");
    return null; // Exit if no token is available
  }

  try {
    // Send the request with the token included in the headers
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add token in Authorization header
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response Data: $data'); // Debugging output to verify response format
      return data['shopId']; // Use the correct key from the API response
    } else {
      print('Failed to fetch shop ID: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching shop ID: $e');
    return null;
  }
}


// Helper function to get the token
Future<String> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') ?? '';
}

}



