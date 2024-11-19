import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController {
  final String apiUrl = 'http://localhost:3000/api/auth';
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      await storage.write(key: 'token', value: jsonResponse['token']);
      return {'success': true, 'message': jsonResponse['message']};
    } else {
      return {'success': false, 'message': json.decode(response.body)['error']};
    }
  }

  // Register function (for the future implementation)
  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'User registered successfully'};
    } else {
      return {'success': false, 'message': json.decode(response.body)['error']};
    }
  }
}
