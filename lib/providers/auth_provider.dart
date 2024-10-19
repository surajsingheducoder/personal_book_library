import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {

  final List<Map<String, String>> _users = [
    {'email': 'admin@example.com', 'password': 'admin123',},
    {'email': 'user1@example.com', 'password': 'user1123',},
    {'email': 'user2@example.com', 'password': 'user2123',},
    {'email': 'user3@example.com', 'password': 'user3123',},
    {'email': 'user4@example.com', 'password': 'user4123',},
  ];

  String? _currentUser;

  String? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void signUp(String email, String password) {
    if (_users.any((user) => user['email'] == email)) {
      throw Exception('Email already exists. Please log in.');
    }
    _users.add({'email': email, 'password': password});
    _currentUser = email;
    notifyListeners();
  }

  void signIn(String email, String password) {
    final user = _users.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
      orElse: () => throw Exception('Invalid email or password.'),
    );

    _currentUser = user['email'];
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
