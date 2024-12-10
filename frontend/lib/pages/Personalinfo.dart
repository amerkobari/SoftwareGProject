import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled/controllers/authController.dart';

final AuthController authcontroller = AuthController();

class PersonalInfoPage extends StatefulWidget {
  final String username;

  const PersonalInfoPage({super.key, required this.username});

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();

  // Helper method to show a SnackBar
  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  String id = '';
  String email = '';
  String phoneNumber = '';
  String birthdate = '';
  bool isLoading = true;
  String errorMessage = '';
  final String baseUrl = "http://10.0.2.2:3000";
  final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  // Controllers for the Reset Password fields
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? verificationCode;
  bool isCodeSent = false;
  bool isCodeVerified = false;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.username);
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/get-user-information/$username'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        setState(() {
          id = data["_id"];
          email = data["email"];
          phoneNumber = data["phoneNumber"];
          birthdate = _formatDate(data["birthdate"]);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'User not found or an error occurred.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCodeSent) ...[
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Enter your email'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (!_emailRegExp.hasMatch(email)) {
                          _showSnackBar(context, 'Please enter a valid email address!');
                          return;
                        }

                        final result = await authcontroller.sendResetCode(email);
                        if (result['success']) {
                          setState(() {
                            isCodeSent = true;
                            verificationCode = result['code']; // Store the code sent by the backend
                          });
                          _showSnackBar(context, 'Verification code sent to $email', isError: false);
                        } else {
                          _showSnackBar(context, 'Failed to send verification code');
                        }
                      },
                      child: const Text('Send Code'),
                    ),
                  ] else if (!isCodeVerified) ...[
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Enter the verification code'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final code = codeController.text.trim();
                        if (code == verificationCode) {
                          setState(() {
                            isCodeVerified = true;
                          });
                          _showSnackBar(context, 'Code verified! You can now reset your password.', isError: false);
                        } else {
                          _showSnackBar(context, 'Invalid verification code. Please try again.');
                        }
                      },
                      child: const Text('Verify Code'),
                    ),
                  ] else ...[
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Enter your new password'),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm your new password'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newPassword = newPasswordController.text.trim();
                        final confirmPassword = confirmPasswordController.text.trim();
                        if (newPassword.isEmpty || confirmPassword.isEmpty) {
                          _showSnackBar(context, 'Password fields cannot be empty.');
                          return;
                        }
                        if (newPassword != confirmPassword) {
                          _showSnackBar(context, 'Passwords do not match.');
                          return;
                        }

                        final result = await authcontroller.resetPassword(
                          emailController.text.trim(),
                          newPassword,
                          verificationCode ?? '',
                        );

                        if (result['success']) {
                          _showSnackBar(context, 'Password reset successfully!', isError: false);
                          Navigator.of(context).pop();
                        } else {
                          _showSnackBar(context, result['message']);
                        }
                      },
                      child: const Text('Reset Password'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Personal Information'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard('ID', id),
                      const SizedBox(height: 16),
                      _buildInfoCard('Username', widget.username),
                      const SizedBox(height: 16),
                      _buildInfoCard('Email', email),
                      const SizedBox(height: 16),
                      _buildInfoCard('Phone Number', phoneNumber),
                      const SizedBox(height: 16),
                      _buildInfoCard('Birthdate', birthdate),
                      const SizedBox(height: 32),
                      _buildResetPasswordButton(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              value.isEmpty ? 'Not Available' : value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetPasswordButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onPressed: () => _resetPassword(),
      child: const Text(
        'Reset Password',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
