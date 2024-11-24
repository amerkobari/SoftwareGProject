import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/controllers/authController.dart';
import 'package:untitled/pages/home.dart';
import 'package:untitled/pages/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController authController = AuthController();

  // Regular expression for email validation
  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  bool _obscurePassword = true; // Password visibility state

  void _validateAndLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please fill in both email and password!');
      return;
    }

    if (!_emailRegExp.hasMatch(email)) {
      _showSnackBar(context, 'Please enter a valid email address!');
      return;
    }

    // Call the AuthController to validate credentials with backend
    var result = await authController.login(email, password);

    if (result['success']) {
      _showSnackBar(context, result['message'], isError: false);

      // Store the token for future requests (e.g., using SharedPreferences)
      final token = result['token'];
      print('Token: $token');

      // Navigate to the home screen or the next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: email)),
      );
    } else {
      _showSnackBar(context, result['message']);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Forgot Password Functionality
  void _forgotPassword(BuildContext context) {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? verificationCode;
  bool isCodeSent = false;
  bool isCodeVerified = false;

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

                      // Call backend to check if email exists and send code
                      final result = await authController.sendResetCode(email);
                      print(result);

                      if (result['success']) {
                        setState(() {
                          isCodeSent = true;
                          verificationCode = result['code']; // Code sent by the backend
                          print('Verification code: $verificationCode');
                          
                        });
                        _showSnackBar(context, 'Verification code sent to $email', isError: false);
                      } else {
                        _showSnackBar(context, result['message']);
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
                      // Verify the code entered by the user with the one sent by the backend
                      final code = codeController.text.trim();
                      if (code == verificationCode) {
                        setState(() {
                          isCodeVerified = true; // Mark code as verified
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

                      // Call backend to reset the password
                      final result = await authController.resetPassword(
                        emailController.text.trim(),
                        newPassword, verificationCode ?? ''
                      );

                      if (result['success']) {
                        _showSnackBar(context, 'Password reset successfully!', isError: false);
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        _showSnackBar(context, result['message']);
                      }
                    },
                    child: const Text('Reset Password'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
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
        title: const Text(
          'HardwareBazzar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Opacity(
            opacity: 0.4, // Adjust transparency
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Login form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white, // Set background color to white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black54, // More visible border color
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black54, // Regular border color
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Highlight border color
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white, // Set background color to white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black54, // More visible border color
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black54, // Regular border color
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Highlight border color
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _validateAndLogin(context),
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
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: TextButton(
                    onPressed: () => _forgotPassword(context),
                    child: const Text(
                      'Forgot Your Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
