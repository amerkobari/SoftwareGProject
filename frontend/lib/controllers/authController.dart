import 'dart:convert';
import 'package:http/http.dart' as http;

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

        return {
          'success': true,
          'message': responseData['message'],
          'token': responseData['token'], // Token returned from backend
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['error'] ?? 'Login failed'};
      }
    } catch (e) {
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
}
