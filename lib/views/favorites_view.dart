import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:stashly/core/constants/app_context_extension.dart';

import '../controllers/bookmark_controller.dart';
import '../controllers/folder_controller.dart';
import '../models/bookmark.dart';

/// View to display favorite bookmarks
class FavoritesView extends StatelessWidget {
  /// Creates a new FavoritesView
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final BookmarkController controller = Get.find<BookmarkController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: context.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text('No favorites yet', style: context.textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Mark bookmarks as favorites to see them here',
                  textAlign: TextAlign.center,
                ),
                if (controller.hasReachedFavoriteLimit.value) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Free limit: ${controller.favorites.length}/${BookmarkController.maxFreeFavorites}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upgrade to premium for unlimited favorites',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.favorites.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final bookmark = controller.favorites[index];
            return _buildFavoriteItem(context, bookmark, controller);
          },
        );
      }),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    Bookmark bookmark,
    BookmarkController controller,
  ) {
    final FolderController folderController = Get.find<FolderController>();

    // Get folder information if bookmark is in a folder
    String? folderName;
    if (bookmark.folderId != null) {
      final folder = folderController.getFolderById(bookmark.folderId!);
      if (folder != null) {
        folderName = folder.name;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                bookmark.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (folderName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder, size: 12, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      folderName,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              bookmark.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(bookmark.getFormattedDate(), style: context.textTheme.bodySmall),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => controller.toggleFavorite(bookmark.id),
        ),
        onTap: () {
          context.pushNamed('bookmarkDetail', pathParameters: {'id': bookmark.id});
        },
      ),
    );
  }
}
