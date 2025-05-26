import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:stashly/core/constants/app_context_extension.dart';

import '../controllers/folder_controller.dart';
import '../models/folder.dart';

/// View for creating or editing a folder
class FolderFormView extends StatefulWidget {
  /// ID of folder to edit (null for new folder)
  final String? folderId;

  /// Creates a new FolderFormView
  const FolderFormView({super.key, this.folderId});

  @override
  State<FolderFormView> createState() => _FolderFormViewState();
}

class _FolderFormViewState extends State<FolderFormView> {
  final FolderController _controller = Get.find<FolderController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedIconName;
  String? _selectedColor;

  bool _isEditMode = false;
  late Folder? _folder;

  final List<Map<String, dynamic>> _folderIcons = [
    {'name': 'folder', 'icon': Icons.folder, 'label': 'Default'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Work'},
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Favorite'},
    {'name': 'travel', 'icon': Icons.travel_explore, 'label': 'Travel'},
    {'name': 'education', 'icon': Icons.school, 'label': 'Education'},
    {'name': 'shopping', 'icon': Icons.shopping_cart, 'label': 'Shopping'},
    {'name': 'personal', 'icon': Icons.person, 'label': 'Personal'},
  ];

  final List<Map<String, dynamic>> _folderColors = [
    {'hex': '#2196F3', 'color': Colors.blue, 'label': 'Blue'},
    {'hex': '#4CAF50', 'color': Colors.green, 'label': 'Green'},
    {'hex': '#F44336', 'color': Colors.red, 'label': 'Red'},
    {'hex': '#FF9800', 'color': Colors.orange, 'label': 'Orange'},
    {'hex': '#9C27B0', 'color': Colors.purple, 'label': 'Purple'},
    {'hex': '#795548', 'color': Colors.brown, 'label': 'Brown'},
    {'hex': '#607D8B', 'color': Colors.blueGrey, 'label': 'Blue Grey'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.folderId != null;

    if (_isEditMode) {
      _folder = _controller.getFolderById(widget.folderId!);
      if (_folder != null) {
        _nameController.text = _folder!.name;
        _descriptionController.text = _folder!.description ?? '';
        _selectedIconName = _folder!.iconName;
        _selectedColor = _folder!.color;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Folder' : 'Create Folder')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_isEditMode && _folder == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: context.getErrorColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('Folder not found', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a folder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Folder Icon',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _folderIcons.map((iconData) {
                    final bool isSelected = _selectedIconName == iconData['name'];
                    return _buildIconOption(
                      context,
                      iconData['icon'] as IconData,
                      iconData['label'] as String,
                      iconData['name'] as String,
                      isSelected,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Folder Color',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _folderColors.map((colorData) {
                    final bool isSelected = _selectedColor == colorData['hex'];
                    return _buildColorOption(
                      context,
                      colorData['color'] as Color,
                      colorData['label'] as String,
                      colorData['hex'] as String,
                      isSelected,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveFolder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_isEditMode ? 'Update Folder' : 'Create Folder'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIconOption(
    BuildContext context,
    IconData icon,
    String label,
    String iconName,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIconName = iconName;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    Color color,
    String label,
    String hexColor,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = hexColor;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _saveFolder() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      bool success;

      if (_isEditMode && _folder != null) {
        success = await _controller.updateFolder(
          id: _folder!.id,
          name: name,
          description: description.isEmpty ? null : description,
          iconName: _selectedIconName,
          color: _selectedColor,
        );
      } else {
        success = await _controller.createFolder(
          name: name,
          description: description.isEmpty ? null : description,
          iconName: _selectedIconName,
          color: _selectedColor,
        );
      }

      if (success) {
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isEditMode ? 'Folder updated' : 'Folder created')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Failed to update folder'
                    : 'Failed to create folder. Name may already be in use.',
              ),
            ),
          );
        }
      }
    }
  }
}
