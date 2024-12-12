import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummarisePage extends StatelessWidget {
  final String subtitlesText;

  const SummarisePage({super.key, required this.subtitlesText});

  Future<String> fetchSummary(String subtitlesText) async {
    final response = await http.post(
      Uri.parse(
          "http://127.0.0.1:8000/summarize"), // Replace with your deployed API URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": subtitlesText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["summary"];
    } else {
      throw Exception("Failed to fetch summary");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subtitle Summary")),
      body: FutureBuilder<String>(
        future: fetchSummary(subtitlesText),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                snapshot.data ?? "No summary available",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}
