import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/folder_controller.dart';
import '../models/folder.dart';

/// A reusable widget for selecting a folder
class FolderSelector extends StatelessWidget {
  /// Current selected folder ID
  final String? selectedFolderId;

  /// Callback when folder selection changes
  final void Function(String?) onFolderSelected;

  /// Create a new FolderSelector widget
  const FolderSelector({required this.selectedFolderId, required this.onFolderSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final folderController = Get.find<FolderController>();

    return Obx(() {
      final List<Folder> folders = folderController.folders;

      return InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Folder',
          prefixIcon: Icon(Icons.folder),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedFolderId,
            isDense: true,
            isExpanded: true,
            hint: const Text('Select a folder'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('None')),
              ...folders.map((folder) {
                return DropdownMenuItem<String?>(
                  value: folder.id,
                  child: Row(
                    children: [
                      Icon(_getIconForFolder(folder), size: 16, color: _getColorForFolder(folder)),
                      const SizedBox(width: 8),
                      Text(folder.name),
                    ],
                  ),
                );
              }),
            ],
            onChanged: onFolderSelected,
          ),
        ),
      );
    });
  }

  /// Get the appropriate icon for a folder
  IconData _getIconForFolder(Folder folder) {
    if (folder.iconName == null) return Icons.folder;

    switch (folder.iconName) {
      case 'work':
        return Icons.work;
      case 'favorite':
        return Icons.favorite;
      case 'travel':
        return Icons.travel_explore;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      case 'personal':
        return Icons.person;
      default:
        return Icons.folder;
    }
  }

  /// Get the color for a folder
  Color? _getColorForFolder(Folder folder) {
    if (folder.color == null || folder.color!.isEmpty) return null;

    try {
      final colorValue = int.parse(folder.color!.replaceFirst('#', ''), radix: 16);
      return Color(colorValue | 0xFF000000); // Add alpha if needed
    } catch (e) {
      return null;
    }
  }
}
