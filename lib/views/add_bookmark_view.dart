import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bookmark_controller.dart';
import '../widgets/folder_selector.dart';

/// View for adding a new bookmark
class AddBookmarkView extends StatefulWidget {
  /// Optional initial URL for the bookmark
  final String? initialUrl;

  /// Creates a new AddBookmarkView
  const AddBookmarkView({this.initialUrl, super.key});

  @override
  State<AddBookmarkView> createState() => _AddBookmarkViewState();
}

class _AddBookmarkViewState extends State<AddBookmarkView> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  final BookmarkController _controller = Get.find<BookmarkController>();

  // Selected folder
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _urlController.text = widget.initialUrl!;
      // TODO: Implement fetching title from URL
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bookmark')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL *',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: _validateUrl,
                autofocus: widget.initialUrl == null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter bookmark title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add a description for your bookmark',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (optional)',
                  hintText: 'tech, news, tutorial (comma separated)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),
              _buildFolderSelector(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBookmark,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('SAVE BOOKMARK', style: TextStyle(fontSize: 16)),
              ),
              Obx(() {
                if (_controller.hasReachedBookmarkLimit.value) {
                  return Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Free Version Limit Reached',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${_controller.bookmarks.length} out of ${BookmarkController.maxFreeBookmarks} bookmarks.',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upgrade to premium for unlimited bookmarks',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement premium upgrade
                          },
                          child: const Text('UPGRADE NOW'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Build the folder selector dropdown
  Widget _buildFolderSelector() {
    return FolderSelector(
      selectedFolderId: _selectedFolderId,
      onFolderSelected: (value) {
        setState(() {
          _selectedFolderId = value;
        });
      },
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  Future<void> _saveBookmark() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Process tags into a list
    final tagsText = _tagsController.text.trim();
    final List<String> tags = tagsText.isNotEmpty
        ? tagsText.split(',').map((tag) => tag.trim()).toList()
        : [];

    // Create bookmark
    final success = await _controller.createBookmark(
      url: _urlController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hashtags: tags,
      folderId: _selectedFolderId,
    );

    if (success) {
      // context.showSnackBar('Bookmark added successfully');
      Navigator.pop(context);
    } else {
      if (_controller.hasReachedBookmarkLimit.value) {
        // context.showSnackBar(
        //   'You\'ve reached the maximum number of bookmarks for the free version',
        //   isError: true,
        // );
      } else {
        // context.showSnackBar('Failed to add bookmark', isError: true);
      }
    }
  }
}
