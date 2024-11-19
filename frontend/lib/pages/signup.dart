import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _validateAndSignUp() {
    // Extract field values
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final birthdate = _birthdateController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation for empty fields
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        birthdate.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('All fields must be filled!');
      return;
    }

    // Username validation (only alphanumeric characters, underscores, and hyphens)
    if (!_isValidUsername(username)) {
      _showSnackBar(
          'Username must only contain letters, numbers, underscores, or hyphens.');
      return;
    }

    // Email validation
    if (!_isValidEmail(email)) {
      _showSnackBar('Invalid email format. Use user@example.com');
      return;
    }

    // Phone number validation
    if (!_isValidPhone(phone)) {
      _showSnackBar('Phone number must start with "05" and have 10 digits.');
      return;
    }

    // Birthdate validation (user should be older than 2015)
    if (!_isOldEnough(birthdate)) {
      _showSnackBar('You must be at least 18 years old!');
      return;
    }

    // Password validation (at least 8 characters, contains letters, numbers, and symbols)
    if (!isPasswordCompliant(password)) {
      _showSnackBar(
          'Password must be at least 8 characters and include letters, numbers, and special characters.');
      return;
    }

    // Confirm password check
    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match!');
      return;
    }

    // If all validations pass, proceed with sign-up logic
    _showSnackBar('Sign-Up Successful!', isError: false);
  }

  bool _isValidUsername(String username) {
    final usernameRegex =
        RegExp(r'^[a-zA-Z0-9_-]+$'); // Letters, numbers, underscores, hyphens
    return usernameRegex.hasMatch(username);
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex =
        RegExp(r'^05\d{8}$'); // Starts with 05 and exactly 10 digits
    return phoneRegex.hasMatch(phone);
  }

  bool _isOldEnough(String birthdate) {
    final dateParts = birthdate.split('-');
    if (dateParts.length == 3) {
      final birthYear = int.tryParse(dateParts[0]);
      final currentYear = DateTime.now().year;

      if (birthYear != null && currentYear - birthYear >= 18) {
        return true;
      }
    }
    return false;
  }

  bool isPasswordCompliant(String password, [int minLength = 8]) {
    if (password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= minLength;

    return hasDigits &&
        hasUppercase &&
        hasLowercase &&
        hasSpecialCharacters &&
        hasMinLength;
  }

  void _showSnackBar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            // Birthdate
            TextField(
              controller: _birthdateController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _birthdateController.text =
                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Birthdate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            // Confirm Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            // Sign Up Button
            Center(
              child: ElevatedButton(
                onPressed: _validateAndSignUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
