import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Ensure you import the ThemeProvider

void showThemeSelectionDialog(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light Mode'),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark Mode'),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System Default'),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
