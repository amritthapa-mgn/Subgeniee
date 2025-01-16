// ignore_for_file: library_private_types_in_public_api, unused_element, unused_field, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:captioneer/screens/homepage1.dart';
import 'package:captioneer/screens/summarize_subtitles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoDisplay extends StatefulWidget {
  final String videoPath;

  const VideoDisplay({super.key, required this.videoPath});

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  late VideoPlayerController _controllerr;

  bool _isPlaying = false;
  List<Map<String, dynamic>> _subtitles = [];
  bool _isTranscribing = false;
  String _currentSubtitle = '';
  Timer? _timer;
  final int _currentSubtitleIndex = 0;
  int _currentPageIndex = 0;

  //state variables for the updated subtitles
  final double _subtitleFontSize = 15;
  final Color _subtitleFontColor = Colors.white;
  final Color _subtitleBackgroundColor = Colors.black54;
  final String _subtitleFontFamily = 'Default';

  final ScrollController _scrollController = ScrollController();

  late TextEditingController
      _projectNameController; // Controller for the text field
  late String _projectName;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _projectNameController =
        TextEditingController(); // Initialize the controller
    _projectName = ''; // Initialize project name as an empty string
  }

  // Show the dialog to input project name
  void _showProjectNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Project Name'),
          content: TextField(
            controller:
                _projectNameController, // Use the controller to manage the text input
            decoration: const InputDecoration(hintText: 'Project Name'),
            onChanged: (value) {
              setState(() {
                _projectName = value; // Update the project name as user types
              });
            },
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                // Close the dialog without saving
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // Save button
            TextButton(
              onPressed: () {
                // Save the project name and call _saveVideo if the project name is not empty
                if (_projectName.isNotEmpty) {
                  _saveVideo();
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show a message if the project name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Project name cannot be empty')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_controllerr.value.isInitialized) {
      _controllerr.dispose();
    }
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _controllerr = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _controllerr.play();
          _isPlaying = true;
        });
        _startSubtitleTimer();
      });
  }

  void _startSubtitleTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      final position = _controllerr.value.position.inMilliseconds;
      final subtitle = _subtitles.firstWhere(
          (s) =>
              position >= (s['start'] * 1000) && position <= (s['end'] * 1000),
          orElse: () => {'text': ''});
      if (_currentSubtitle != subtitle['text']) {
        setState(() {
          _currentSubtitle = subtitle['text'];
        });
      }

      // Scroll the timeline based on video position
      if (_subtitles.isNotEmpty) {
        final index =
            _subtitles.indexWhere((s) => s['start'] * 1000 > position);
        if (index > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                (index - 1) * 50.0, // Adjust height as needed
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            } else {
              print("ScrollController not attached to a scrollable widget.");
            }
          });
        }
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controllerr.value.isPlaying) {
        _controllerr.pause();
      } else {
        _controllerr.play();
      }
      _isPlaying = _controllerr.value.isPlaying;
    });
  }

  Future<void> _startTranscription() async {
    if (widget.videoPath.isNotEmpty) {
      setState(() {
        _isTranscribing = true;
      });
      try {
        final response = await convertSpeechToText(widget.videoPath);
        if (response != null) {
          setState(() {
            _subtitles = response;
            _isTranscribing = false;
          });
        } else {
          _showSnackbar("Failed to generate subtitles.");
        }
      } catch (e) {
        _showSnackbar('Exception: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isTranscribing = false;
          });
        }
      }
    } else {
      _showSnackbar("No video selected.");
    }
  }

  Future<List<Map<String, dynamic>>?> convertSpeechToText(
      String videoPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/transcribe'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', videoPath));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final result = jsonDecode(responseData.body) as Map<String, dynamic>;
        return (result['segments'] as List)
            .map((seg) => {
                  'start': seg['start'],
                  'end': seg['end'],
                  'text': seg['text'],
                })
            .toList();
      } else {
        _showSnackbar('Error: ${responseData.body}');
        return null;
      }
    } catch (e) {
      _showSnackbar('Exception: $e');
      return null;
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToEditSubtitles() {
    debugPrint('Navigating to edit subtitles...');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double fontSize = 15;
        Color fontColor = Colors.white;
        Color backgroundColor = Colors.black54;
        String fontFamily = 'Default';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          setModalState(() {
                            fontSize = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Font Color Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            setModalState(() {
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
                            setModalState(() {
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
                            setModalState(() {
                              fontFamily = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  //code updated

                  // Save Button before updating
                  ElevatedButton(
                    onPressed: () {
                      // Save the changes and update subtitle style
                      setState(() {
                        // Update subtitle style or save settings here

                        // _subtitleStyle = TextStyle(
                        //   fontSize: fontSize,
                        //   color: fontColor,
                        //   backgroundColor: backgroundColor,
                        //   fontFamily: fontFamily == 'Default' ? null : fontFamily,
                        // );
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_currentPageIndex) {
      case 0: // Subtitle Edit/Format
        return _subtitles.isEmpty
            ? ElevatedButton(
                onPressed: _isTranscribing ? null : _startTranscription,
                child: _isTranscribing
                    ? const CircularProgressIndicator()
                    : const Text("Start Generating Subtitles"),
              )
            : ListView.builder(
                itemCount: _subtitles.length,
                itemBuilder: (context, index) {
                  final subtitle = _subtitles[index];
                  return ListTile(
                    title: Text(
                      subtitle['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      if (_currentPageIndex == 0) {
                        debugPrint('Editing subtitle: ${subtitle['text']}');
                        // Use Builder to get a fresh context
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Builder(
                              builder: (context) {
                                debugPrint('Showing bottom sheet');
                                _navigateToEditSubtitles();
                                return Container(); // No UI, just to show context used
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                },
              );

      case 1: // Subtitle Summarization
        return _subtitles.isEmpty
            ? ElevatedButton(
                onPressed: _isTranscribing ? null : _startTranscription,
                child: _isTranscribing
                    ? const CircularProgressIndicator()
                    : const Text("Start Generating Subtitles"),
              )
            : ListView.builder(
                itemCount: _subtitles.length,
                itemBuilder: (context, index) {
                  final subtitle = _subtitles[index];
                  return ListTile(
                    title: Text(
                      subtitle['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      setState(() {
                        _currentPageIndex = 1; // Navigate to Summarize directly
                      });
                      _navigateToSummarisePage(context, _subtitles);
                    },
                  );
                },
              );
      case 2: // Export
        return ElevatedButton(
          onPressed: () {
            _showSnackbar("Subtitles exported!");
          },
          child: const Text("Export Subtitles"),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showProjectNameDialog,
            // Save button action
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _controllerr.value.isInitialized
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 350,
                            height: 622.22223,
                            child: AspectRatio(
                              aspectRatio: _controllerr.value.aspectRatio,
                              child: VideoPlayer(_controllerr),
                            ),
                          ),
                          IconButton(
                            iconSize: 64.0,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          Positioned(
                            bottom: 20,
                            child: Text(
                              _currentSubtitle,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_subtitles
                          .isEmpty) // Show button only if no subtitles
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed:
                                _isTranscribing ? null : _startTranscription,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isTranscribing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Start Generating",
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        )
                      else // Display subtitle timeline
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Stack(
                            children: [
                              // Center Line
                              Positioned(
                                left: MediaQuery.of(context).size.width / 2 - 2,
                                child: Container(
                                  width: 4,
                                  height: 50,
                                  color: Colors.red, // Center line
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 350,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollController,
                                  child: Row(
                                    children: List.generate(
                                      _subtitles.length,
                                      (index) {
                                        final subtitle = _subtitles[index];
                                        final isActive =
                                            index == _currentSubtitleIndex;

                                        return GestureDetector(
                                          onTap: () {
                                            _controllerr.seekTo(Duration(
                                                seconds:
                                                    subtitle['start'].toInt()));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                // Edit Subtitle in place
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    TextEditingController
                                                        controller =
                                                        TextEditingController(
                                                            text: subtitle[
                                                                'text']);
                                                    return AlertDialog(
                                                      title: const Text(
                                                        "Edit Subtitle",
                                                      ),
                                                      content: TextField(
                                                        controller: controller,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Edit Subtitle',
                                                        ),
                                                        onSubmitted: (newText) {
                                                          setState(() {
                                                            subtitle['text'] =
                                                                newText;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                subtitle['text'],
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      bottomNavigationBar: _subtitles.isNotEmpty
          ? BottomNavigationBar(
              currentIndex: _currentPageIndex,

              onTap: _handleBottomNavigationTap,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: 'Edit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.summarize),
                  label: 'Summarize',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.download),
                  label: 'Export',
                ),
              ],
              //Custom styling for font and size for bottomnav labels
              selectedLabelStyle: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 140, 255)),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              iconSize: 30, // Adjust the size of the icons
            )
          : null,
    );
  }

  void _handleBottomNavigationTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    if (index == 1) {
      _navigateToSummarisePage(context, _subtitles);
    }
  }

  void _navigateToSummarisePage(
      BuildContext context, List<Map<String, dynamic>> subtitles) {
    if (subtitles.isEmpty) {
      debugPrint("No subtitles available for summarization.");
      return;
    }

    // Concatenate subtitles
    String subtitlesText = subtitles.map((e) => e['text']).join(" ");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummarisePage(subtitlesText: subtitlesText),
      ),
    );
  }

  // Save the video data to Supabase
  void _saveVideo() async {
    try {
      // Get video length from the VideoPlayerController
      final videoLength = _controllerr.value.duration.inSeconds;

      // Insert video data into Supabase table
      final response = await Supabase.instance.client
          .from('videos') // Your table name
          .insert({
        'video_path': widget.videoPath, // Replace with the actual video path
        'project_name': _projectName, // Replace with your project name
        'subtitles':
            _subtitles.map((e) => e['text']).toList(), // Subtitle texts
        'video_length': videoLength, // Duration in seconds
      });

      // Check if the response is not null
      if (response != null && response.error != null) {
        print('Error saving video: ${response.error!.message}');
      } else {
        print('Video saved successfully!');
        Navigator.of(context).pop(); // Pops the current screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage1(
            title: '',
          ),
        ));
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
