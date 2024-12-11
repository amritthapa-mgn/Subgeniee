// ignore_for_file: prefer_const_constructors

import 'package:captioneer/Screens/signup_screen.dart';
import 'package:captioneer/auth/auth_services.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
// get auth services
  final authService = AuthServices();

  //text editing controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //login button clicked
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SUBGenie",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: -2.5,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 170, vertical: 15), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Button border radius
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 18, // Font size of the text
                  fontWeight: FontWeight.bold, // Font weight
                  letterSpacing: -1.0, // Letter spacing
                ),
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                InkWell(
                  child: Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Default text color
                      decoration: TextDecoration.underline, // Underline text
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
