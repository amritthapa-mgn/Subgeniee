import 'package:flutter/material.dart';

class SubtitleEditPage extends StatefulWidget {
  const SubtitleEditPage({super.key});

  @override
  _SubtitleEditPageState createState() => _SubtitleEditPageState();
}

class _SubtitleEditPageState extends State<SubtitleEditPage> {
  double fontSize = 15;
  Color fontColor = Colors.white;
  Color backgroundColor = Colors.black54;
  String fontFamily = 'Default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Subtitles')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample Text Display
            Text(
              "Sample Subtitle Text",
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                backgroundColor: backgroundColor,
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
              ),
            ),
            const SizedBox(height: 20),

            // Font Size Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Font Size"),
                Slider(
                  value: fontSize,
                  min: 10,
                  max: 30,
                  divisions: 20,
                  label: fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      fontSize = value;
                    });
                  },
                ),
              ],
            ),

            // Font Color Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Font Color"),
                DropdownButton<Color>(
                  value: fontColor,
                  items: [
                    Colors.white,
                    Colors.black,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                  ]
                      .map((color) => DropdownMenuItem<Color>(
                            value: color,
                            child: Container(
                              width: 20,
                              height: 20,
                              color: color,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        fontColor = value;
                      });
                    }
                  },
                ),
              ],
            ),

            // Background Color Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Background Color"),
                DropdownButton<Color>(
                  value: backgroundColor,
                  items: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.white,
                    Colors.redAccent,
                    Colors.blueAccent,
                  ]
                      .map((color) => DropdownMenuItem<Color>(
                            value: color,
                            child: Container(
                              width: 20,
                              height: 20,
                              color: color,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        backgroundColor = value;
                      });
                    }
                  },
                ),
              ],
            ),

            // Font Family Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Font Family"),
                DropdownButton<String>(
                  value: fontFamily,
                  items: [
                    'Default',
                    'Roboto',
                    'Arial',
                    'Courier New',
                    'Times New Roman',
                  ]
                      .map((font) => DropdownMenuItem<String>(
                            value: font,
                            child: Text(font),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        fontFamily = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save the changes and update subtitle style (if needed)
                setState(() {
                  // Update subtitle style or save settings here
                });
                Navigator.pop(context); // Close the page
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
