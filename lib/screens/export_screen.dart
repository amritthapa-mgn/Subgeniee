// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class VideoExportPage extends StatefulWidget {
  const VideoExportPage({super.key});

  @override
  _VideoExportPageState createState() => _VideoExportPageState();
}

class _VideoExportPageState extends State<VideoExportPage> {
  // Default selected values
  String selectedResolution = '1080p';
  String selectedFormat = 'MP4';

  // List of resolutions and formats
  final List<String> resolutions = ['1080p', '720p', '4K'];
  final List<String> formats = ['MP4', 'MOV'];

  void exportVideo() {
    // In a real scenario, you would use packages like flutter_ffmpeg
    print('Exporting video...');
    print('Resolution: $selectedResolution');
    print('Format: $selectedFormat');

    // For now, just showing a dialog after the export is initiated
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Successful'),
          content: Text(
              'Video exported as $selectedResolution in $selectedFormat format.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resolution Dropdown
            const Text('Select Resolution:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedResolution,
              onChanged: (String? newValue) {
                setState(() {
                  selectedResolution = newValue!;
                });
              },
              items: resolutions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Format Dropdown
            const Text('Select Format:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedFormat,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFormat = newValue!;
                });
              },
              items: formats.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Export Button
            Center(
              child: ElevatedButton(
                onPressed: exportVideo,
                child: const Text(
                  'Export Video',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
