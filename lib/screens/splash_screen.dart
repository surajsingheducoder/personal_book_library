import 'dart:async';
import 'package:flutter/material.dart';
import 'package:personal_book_library/screens/home_screen.dart';
import 'package:personal_book_library/screens/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    String? userEmail = prefs.getString('userEmail');
    print("check email: $userEmail");


    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(userEmail: "$userEmail"),));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen(),));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: Colors.black,
              radius: 40,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(child: Icon(Icons.menu_book, color: Colors.white, size: screenHeight/15,)),
                ),
            ),
            SizedBox(height: screenHeight/50,),
            Text(
              'Welcome to\nPersonal Book Library', textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenHeight/48, fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}