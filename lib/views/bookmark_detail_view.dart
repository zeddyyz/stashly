import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stashly/core/constants/app_context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/bookmark_controller.dart';
import '../controllers/folder_controller.dart';
import '../models/bookmark.dart';
import '../models/folder.dart';
import '../widgets/offline_available_badge.dart';

/// Shows the details of a bookmark
class BookmarkDetailView extends StatelessWidget {
  /// The ID of the bookmark to display
  final String bookmarkId;

  /// Creates a new BookmarkDetailView
  const BookmarkDetailView({required this.bookmarkId, super.key});

  @override
  Widget build(BuildContext context) {
    final BookmarkController controller = Get.find<BookmarkController>();
    final FolderController folderController = Get.find<FolderController>();

    return Obx(() {
      // Find the bookmark
      final bookmark = controller.bookmarks.firstWhereOrNull((b) => b.id == bookmarkId);

      if (bookmark == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Not Found')),
          body: const Center(child: Text('Bookmark not found')),
        );
      }

      // Find folder if bookmark has one
      Folder? folder;
      if (bookmark.folderId != null) {
        folder = folderController.getFolderById(bookmark.folderId!);
      }

      // Record access when viewing details (for offline availability)
      controller.recordBookmarkAccess(bookmarkId);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Bookmark Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.pushNamed('editBookmark', pathParameters: {'id': bookmarkId});
              },
            ),
            IconButton(
              icon: Icon(
                bookmark.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: bookmark.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                controller.toggleFavorite(bookmarkId);
              },
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(children: [Icon(Icons.share), SizedBox(width: 8), Text('Share')]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _shareBookmark(bookmark);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, controller, bookmark);
                    break;
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(bookmark.url),
                        child: Text(
                          bookmark.url,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      if (bookmark.description != null && bookmark.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Description', style: context.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(bookmark.description!, style: context.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: context.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Saved on ${bookmark.getFormattedDate()}',
                            style: context.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          OfflineAvailableBadge(bookmarkId: bookmark.id),
                        ],
                      ),
                      if (folder != null) ...[
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            // Select this folder and navigate to home view
                            folderController.selectFolder(folder!);
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder,
                                  size: 16,
                                  color: context.colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  folder.name,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (bookmark.hashtags.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Tags', style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bookmark.hashtags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: context.colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: context.colorScheme.onPrimaryContainer),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(bookmark.url),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareBookmark(Bookmark bookmark) {
    Share.share('${bookmark.title}\n${bookmark.url}');
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BookmarkController controller,
    Bookmark bookmark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete "${bookmark.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteBookmark(bookmark.id);
      Navigator.pop(context);
    }
  }
}
