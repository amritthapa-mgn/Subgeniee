// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'video_display1.dart';
import 'package:captioneer/themes/_show_theme_selection_dialog.dart';
import 'package:http/http.dart' as http;

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key, required this.title});

  final String title;

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  String? _videoURL;
  String? _selectedLanguage; // Variable to store selected language

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SubGENIE',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 5),
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.userMetadata?['name'] ?? 'user'),
              accountEmail: Text(user?.email ?? 'No email available'),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text(
                'Switch Theme',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                showThemeSelectionDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
            ),
            const Divider(),
          ],
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Create New Project',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      builder: (context) {
        String? selectedLanguage;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 38, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: Colors.blue[100],
                      value:
                          selectedLanguage, // The value will update with the selected language
                      hint: const Text(
                        'Select Language',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 35,
                      ),
                      underline: const SizedBox(),
                      items:
                          _buildDropdownItems(), // Call the method to build dropdown items
                      onChanged: (String? newValue) {
                        setModalState(() {
                          selectedLanguage =
                              newValue; // Update the selected language
                        });
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _buildDropdownItems()
                            .map<Widget>((DropdownMenuItem<String> item) {
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.value ?? '', // Display the selected item
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Use the same color as the hint text
                                letterSpacing: -1.0,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String? pickedVideo = await _pickVideo();

                      if (!mounted) {
                        return; // Ensure the widget is still in the tree.
                      }

                      if (pickedVideo != null) {
                        setState(() {
                          _videoURL = pickedVideo;
                        });

                        if (context.mounted) {
                          // Double-check before navigating.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoDisplay(videoPath: _videoURL!),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          // Check before showing a SnackBar.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No video selected!')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Select from Photos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String? pickedVideo = await _pickVideo();
                      if (pickedVideo != null) {
                        setState(() {
                          _videoURL = pickedVideo;
                        });
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoDisplay(videoPath: _videoURL!),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No video selected!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 160, vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Record',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final languages = [
      'US - English🇺🇸 ',
      'Nepali - नेपाली🇳🇵',
    ]; // List of languages
    return languages.map((language) {
      return DropdownMenuItem<String>(
        value: language,
        child: Text(
          language, // Display the language text as it is
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Unified color for all items
          ),
        ),
      );
    }).toList();
  }

  Future<String?> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        return video.path;
      } else {
        debugPrint("No video selected.");
        return null;
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
      return null;
    }
  }

  Future<void> transcribeAudio() async {
    final uri =
        Uri.parse('http://127.0.0.1:8000/transcribe'); // Backend endpoint
    final request = http.MultipartRequest('POST', uri);

    // Add the selected language to the request
    request.fields['language'] = _selectedLanguage!;

    // Send the request
    final response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      print("Transcription success!");
      // You can parse and use the response body here
    } else {
      print("Transcription failed");
    }
  }
}
