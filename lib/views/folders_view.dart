import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:stashly/core/constants/app_context_extension.dart';

import '../controllers/folder_controller.dart';
import '../models/folder.dart';

/// View that displays and manages folders
class FoldersView extends StatefulWidget {
  /// Creates a new FoldersView instance
  const FoldersView({super.key});

  static const String routePath = '/folders';
  static const String routeName = 'folders';

  @override
  State<FoldersView> createState() => _FoldersViewState();
}

class _FoldersViewState extends State<FoldersView> {
  final FolderController _controller = Get.find<FolderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_controller.hasReachedFolderLimit.value) {
                _showFolderLimitReachedDialog(context);
              } else {
                context.pushNamed('createFolder');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.folders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 64,
                  color: context.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text('No folders yet', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Create folders to organize your bookmarks',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_controller.hasReachedFolderLimit.value) {
                      _showFolderLimitReachedDialog(context);
                    } else {
                      context.pushNamed('createFolder');
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create folder'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _controller.folders.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final folder = _controller.folders[index];
            final bookmarkCount = _controller.getBookmarkCountInFolder(folder.id);
            return _buildFolderItem(context, folder, bookmarkCount);
          },
        );
      }),
    );
  }

  Widget _buildFolderItem(BuildContext context, Folder folder, int bookmarkCount) {
    // Determine which icon to use (either the specified one or a default)
    IconData folderIcon = Icons.folder;
    if (folder.iconName != null) {
      // This is a simple implementation - in a real app you'd have a mapping
      // or more sophisticated way to handle dynamic icons
      switch (folder.iconName) {
        case 'work':
          folderIcon = Icons.work;
          break;
        case 'favorite':
          folderIcon = Icons.favorite;
          break;
        case 'travel':
          folderIcon = Icons.travel_explore;
          break;
        case 'education':
          folderIcon = Icons.school;
          break;
        case 'shopping':
          folderIcon = Icons.shopping_cart;
          break;
        case 'personal':
          folderIcon = Icons.person;
          break;
        default:
          folderIcon = Icons.folder;
      }
    }

    // Parse color if provided
    Color? folderColor;
    if (folder.color != null && folder.color!.isNotEmpty) {
      try {
        final colorValue = int.parse(folder.color!.replaceFirst('#', ''), radix: 16);
        folderColor = Color(colorValue | 0xFF000000); // Add alpha if needed
      } catch (e) {
        // Use default color if parsing fails
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Set this folder as selected and navigate to home view
          _controller.selectFolder(folder);
          Get.until((route) => Get.currentRoute == '/');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: folderColor ?? Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  folderIcon,
                  color: folderColor != null
                      ? ThemeData.estimateBrightnessForColor(folderColor) == Brightness.dark
                            ? Colors.white
                            : Colors.black
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (folder.description != null && folder.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        folder.description!,
                        style: context.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '$bookmarkCount bookmark${bookmarkCount == 1 ? '' : 's'}',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.pushNamed('editFolder', pathParameters: {'id': folder.id});
                  } else if (value == 'delete') {
                    _showDeleteFolderDialog(context, folder);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')]),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteFolderDialog(BuildContext context, Folder folder) {
    final bookmarkCount = _controller.getBookmarkCountInFolder(folder.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"?\n\n'
          'This folder contains $bookmarkCount bookmark${bookmarkCount == 1 ? '' : 's'}. '
          'The bookmarks will not be deleted but they will no longer be in this folder.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _controller.deleteFolder(folder.id);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Folder deleted')));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Failed to delete folder')));
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showFolderLimitReachedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Folder Limit Reached'),
        content: const Text(
          'You\'ve reached the maximum number of folders (3) allowed in the free version.\n\n'
          'Upgrade to premium to create unlimited folders.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium upgrade page
            },
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
  }
}
