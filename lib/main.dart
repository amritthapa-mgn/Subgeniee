import 'package:captioneer/auth/auth_gate.dart';
import 'package:captioneer/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://wvfvmvixehzbcuwvefrt.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2ZnZtdml4ZWh6YmN1d3ZlZnJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMwMjI3NDQsImV4cCI6MjA0ODU5ODc0NH0.tokOP6lO4E6JaNd_C8i2i4plGOIv1nDo7P8iik4JQFE");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Provide ThemeProvider to the app
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: themeProvider.themeMode, // Use theme from ThemeProvider
      home: const AuthGate(),
    );
  }
}
