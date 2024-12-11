import 'package:flutter/material.dart';

class EditableListView extends StatefulWidget {
  const EditableListView({super.key});

  @override
  State<EditableListView> createState() => _EditableListViewState();
}

class _EditableListViewState extends State<EditableListView> {
  // List of items
  final List<Map<String, String>> _items = [
    {'title': 'Project 1', 'description': 'Subtitle project for video 1'},
    {'title': 'Project 2', 'description': 'Subtitle project for video 2'},
    {'title': 'Project 3', 'description': 'Subtitle project for video 3'},
  ];

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index); // Delete item
              });
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    final titleController = TextEditingController(text: _items[index]['title']);
    final descriptionController =
        TextEditingController(text: _items[index]['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items[index] = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                }; // Update item
              });
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.folder, color: Colors.blue),
            title: Text(item['title'] ?? 'Untitled'),
            subtitle: Text(item['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _editItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
