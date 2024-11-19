class User {
  final String email;
  final String password;

  User({required this.email, required this.password});

  // Convert User object to JSON format to send to API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Create User object from API response
  static User fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
    );
  }
}
