// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:captioneer/auth/auth_services.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
// get auth services
  final authService = AuthServices();

  //text editing controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  //login button clicked

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }
    try {
      await authService.signUpWithEmailPassword(email, password);

      Navigator.pop(context);
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
      appBar: AppBar(
        title: Text(""),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
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

            //Email field
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

            //password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),

            //Comfirm Password
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 18),
            //
            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 160, vertical: 18), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Button border radius
                ),
              ),
              child: const Text(
                'Signup',
                style: TextStyle(
                  fontSize: 18, // Font size of the text
                  fontWeight: FontWeight.bold, // Font weight
                  letterSpacing: -1.0, // Letter spacing
                ),
              ),
            ),

            SizedBox(height: 130),
          ],
        ),
      ),
    );
  }
}
