import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {

   List<Map<String, dynamic>> _users = [
    {'email': 'admin@example.com', 'password': 'admin123',},
    {'email': 'user1@example.com', 'password': 'user1123',},
    {'email': 'user2@example.com', 'password': 'user2123',},
    {'email': 'user3@example.com', 'password': 'user3123',},
    {'email': 'user4@example.com', 'password': 'user4123',},
  ];

  String? _currentUser;

  String? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<dynamic> signUp(String email, String password) async{
      await getAllUsers();
    if (_users.any((user) => user['email'] == email)) {
      throw Exception('Email already exists. Please log in.');
    }

    _users.add({'email': email, 'password': password});
   await addNewUser();
    _currentUser = email;

    notifyListeners();
  }

  Future<dynamic> signIn(String email, String password) async{
    try{
      await getAllUsers();

      final user = _users.firstWhere(
            (user) => user['email'] == email && user['password'] == password,
        orElse: () => throw Exception('Invalid email or password.'),
      );
      _currentUser = user['email'];
      notifyListeners();
    }catch(e){
      print(e);
      throw Exception('Invalid email or password. ');
    }


  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  Future getAllUsers() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
   var data = prefs.getString('allUsers');
   List<dynamic>? usersList = jsonDecode(data ?? "[]");
    if(usersList != null){
      var newUsers = usersList.where((element) => _users.contains(element) == false);
      _users.addAll(newUsers.map((e) => jsonDecode(jsonEncode(e))));
      notifyListeners();
    }

    print("users list => ${_users}");
  }

  Future addNewUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('allUsers',jsonEncode(_users));
    notifyListeners();
  }
}
