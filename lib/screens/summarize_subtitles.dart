// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class SummarisePage extends StatelessWidget {
  final List<Map<String, dynamic>> subtitles;
  SummarisePage({required this.subtitles});

  @override
  Widget build(BuildContext context) {
    // Generate a summary of the subtitles
    final summary = _generateSummary(subtitles);

    return Scaffold(
      appBar: AppBar(
        title: Text("Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  summary,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate a summary
  String _generateSummary(List<Map<String, dynamic>> subtitles) {
    // Safely convert dynamic to String for summarization
    final combinedText =
        subtitles.map((s) => s['text']?.toString() ?? '').join(' ');

    return "This is a summary of the subtitles:\n\n$combinedText";
  }
}
