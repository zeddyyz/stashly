import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bookmark_controller.dart';
import '../models/bookmark.dart';
import '../widgets/folder_selector.dart';

/// View for editing an existing bookmark
class EditBookmarkView extends StatefulWidget {
  /// ID of the bookmark to edit
  final String bookmarkId;

  /// Creates a new EditBookmarkView
  const EditBookmarkView({required this.bookmarkId, super.key});

  @override
  State<EditBookmarkView> createState() => _EditBookmarkViewState();
}

class _EditBookmarkViewState extends State<EditBookmarkView> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  final BookmarkController _controller = Get.find<BookmarkController>();

  String? _selectedFolderId;
  bool _isFavorite = false;

  late Bookmark? _bookmark;

  @override
  void initState() {
    super.initState();
    _loadBookmarkData();
  }

  void _loadBookmarkData() {
    _bookmark = _controller.bookmarks.firstWhereOrNull((b) => b.id == widget.bookmarkId);

    if (_bookmark != null) {
      _urlController.text = _bookmark!.url;
      _titleController.text = _bookmark!.title;
      _descriptionController.text = _bookmark!.description ?? '';
      _tagsController.text = _bookmark!.hashtags.join(', ');
      _selectedFolderId = _bookmark!.folderId;
      _isFavorite = _bookmark!.isFavorite;
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
      appBar: AppBar(
        title: const Text('Edit Bookmark'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_bookmark == null) {
          return const Center(child: Text('Bookmark not found'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
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
                FolderSelector(
                  selectedFolderId: _selectedFolderId,
                  onFolderSelected: (value) {
                    setState(() {
                      _selectedFolderId = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updateBookmark,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Text('UPDATE BOOKMARK', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      }),
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

  Future<void> _updateBookmark() async {
    if (_formKey.currentState?.validate() != true || _bookmark == null) {
      return;
    }

    // Process tags into a list
    final tagsText = _tagsController.text.trim();
    final List<String> tags = tagsText.isNotEmpty
        ? tagsText.split(',').map((tag) => tag.trim()).toList()
        : [];

    // Update bookmark
    final success = await _controller.updateBookmark(
      id: _bookmark!.id,
      url: _urlController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hashtags: tags,
      folderId: _selectedFolderId,
      isFavorite: _isFavorite,
    );

    // if (success) {
    //   context.showSnackBar('Bookmark updated successfully');
    //   Navigator.pop(context);
    // } else {
    //   if (_controller.hasReachedFavoriteLimit.value && _isFavorite) {
    //     context.showSnackBar(
    //       'You\'ve reached the maximum number of favorites for the free version',
    //       isError: true,
    //     );
    //   } else {
    //     context.showSnackBar('Failed to update bookmark', isError: true);
    //   }
    // }
  }
}
