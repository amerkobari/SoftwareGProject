import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController {
  final String baseUrl = "http://10.0.2.2:3000"; // Replace with your backend URL

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

        // Assuming token is returned in the response
        final token = responseData['token'];

        return {
          'success': true,
          'message': responseData['message'],
          'token': token,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }

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
        return {'success': false, 'message': responseData['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server.'};
    }
  }
}