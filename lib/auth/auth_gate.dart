//AUTH GATE - This will continuousty listen for auth change state

// unauthenticated → Login Page
// authenticated-> Profile Page

import 'package:captioneer/screens/homepage1.dart';
import 'package:captioneer/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // Listen to auth state changes
        stream: Supabase.instance.client.auth.onAuthStateChange,
        // Build appropriate page based on auth state
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return const HomePage1(title: 'Hello');
          } else {
            return const LoginScreen();
          }
        });
  }
}

// StreamBuilder
