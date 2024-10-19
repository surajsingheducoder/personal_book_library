import 'package:flutter/material.dart';
import 'package:personal_book_library/screens/home_screen.dart';
import 'package:personal_book_library/screens/signin_screen.dart';
import 'package:personal_book_library/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> storeLoginData(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store login status
    await prefs.setBool('isLoggedIn', true);

    // Store user email
    await prefs.setString('userEmail', email);
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
       await Provider.of<AuthProvider>(context, listen: false).signUp(_emailController.text.trim(), _passwordController.text.trim());
        _showSnackbar('Sign-up successful!');
        storeLoginData(_emailController.text.trim());
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen(userEmail: _emailController.text),), (route) => false);
      } catch (e) {
        _showSnackbar(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight / 3.5),
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight / 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight / 20),
                CustomTextField(
                  label: 'Enter email',
                  controller: _emailController,
                  iconData: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight / 80),
                CustomTextField(
                  label: 'Enter password',
                  controller: _passwordController,
                  iconData: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: screenHeight / 30),

                CustomButton(text: 'SignUp', onPressed: _signUp),

                SizedBox(height: screenHeight / 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}