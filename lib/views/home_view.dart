import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/bookmark_controller.dart';
import '../controllers/folder_controller.dart';
import '../models/bookmark.dart';
import '../widgets/offline_indicator.dart';

/// Home view displaying the list of bookmarks
class HomeView extends StatefulWidget {
  /// Creates a new HomeView instance
  const HomeView({super.key});

  static const String routePath = '/';
  static const String routeName = 'home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final BookmarkController _bookmarkController = Get.find<BookmarkController>();
  final FolderController _folderController = Get.find<FolderController>();

  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();
    // Listen to folder selection changes
    ever(_folderController.selectedFolder, (folder) {
      if (folder != null) {
        _bookmarkController.selectedFolderId.value = folder.id;
      } else {
        _bookmarkController.selectedFolderId.value = '';
      }
    });

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        _showAddDialog(context);
        print("getIntentDataStream: $value");
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);

          print(_sharedFiles.map((f) => f.toMap()));
        });
      },
      onError: (err) {
        print("getIntentDataStream error: $err");
      },
    );

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then(
      (value) {
        print("getInitialMedia: $value");
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
          print(_sharedFiles.map((f) => f.toMap()));

          // Tell the library that we are done processing the intent.
          ReceiveSharingIntent.instance.reset();
        });
      },
      onError: (err) {
        print("getInitialMedia error: $err");
      },
    );
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: const Text('This feature is not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Obx(() {
          final selectedFolder = _folderController.selectedFolder.value;
          return Text(selectedFolder != null ? selectedFolder.name : 'Stashly');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              context.pushNamed('favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_bookmarkController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_bookmarkController.bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text('No bookmarks yet', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Share links from other apps or add them manually',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed('addBookmark');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add manually'),
                ),
                const SizedBox(height: 24),
                Text("Shared files:", style: Theme.of(context).textTheme.titleMedium),
                Text(_sharedFiles.map((f) => f.type.value).join(", ")),
              ],
            ),
          );
        }

        // Get filtered bookmarks based on current filters and offline state
        final displayedBookmarks = _bookmarkController.getFilteredBookmarks();

        // Show folder empty state if needed
        if (displayedBookmarks.isEmpty &&
            _bookmarkController.selectedFolderId.isNotEmpty &&
            !_bookmarkController.isOfflineMode.value) {
          final folder = _folderController.getFolderById(
            _bookmarkController.selectedFolderId.value,
          );
          if (folder != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks in this folder',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add bookmarks to "${folder.name}" to see them here',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('addBookmark');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add bookmark'),
                  ),
                ],
              ),
            );
          }
        }

        // Offline mode with no bookmarks
        if (displayedBookmarks.isEmpty && _bookmarkController.isOfflineMode.value) {
          return Column(
            children: [
              const OfflineIndicator(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks available offline',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Open a bookmark to make it available offline',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Show bookmarks
        return Column(
          children: [
            const OfflineIndicator(),
            _buildFolderFilter(),
            Expanded(
              child: ListView.builder(
                itemCount: displayedBookmarks.length,
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) {
                  final bookmark = displayedBookmarks[index];
                  return _buildBookmarkItem(context, bookmark);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('addBookmark');
        },
        tooltip: 'Add Bookmark',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Stashly'),
            accountEmail: const Text('Your personal bookmark manager'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.bookmark, color: Colors.white, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('All Bookmarks'),
            onTap: () {
              _folderController.clearSelectedFolder();
              _bookmarkController.selectedFolderId.value = '';
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Folders'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.pushNamed('folders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.pushNamed('favorites');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.pushNamed('settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFolderFilter() {
    return Obx(() {
      final selectedFolderId = _bookmarkController.selectedFolderId.value;
      if (selectedFolderId.isEmpty) return const SizedBox.shrink();

      final folder = _folderController.getFolderById(selectedFolderId);
      if (folder == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            Text(
              'Folder: ${folder.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _folderController.clearSelectedFolder();
                _bookmarkController.selectedFolderId.value = '';
              },
              tooltip: 'Clear folder filter',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBookmarkItem(BuildContext context, Bookmark bookmark) {
    // Check if this bookmark is available offline
    final isOfflineAvailable = _bookmarkController.isBookmarkOfflineAvailable(bookmark.id);

    // Get folder info if bookmark is in a folder
    String? folderName;
    if (bookmark.folderId != null) {
      final folder = _folderController.getFolderById(bookmark.folderId!);
      if (folder != null) {
        folderName = folder.name;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // context.pushNamed('bookmarkDetail', pathParameters: {'id': bookmark.id});
          launchUrlString(bookmark.url);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bookmark.title,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      bookmark.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: bookmark.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      _bookmarkController.toggleFavorite(bookmark.id);
                    },
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (bookmark.description != null && bookmark.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  bookmark.description!,
                  style: context.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                bookmark.url,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(bookmark.getFormattedDate(), style: context.textTheme.bodySmall),
                      const SizedBox(width: 8),
                      if (isOfflineAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.offline_pin,
                                size: 10,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (folderName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder,
                            size: 10,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            folderName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (bookmark.hashtags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bookmark.hashtags.map((tag) => '#$tag').join(' '),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              AnyLinkPreview.builder(
                link: bookmark.url,
                cache: Duration(days: 30),
                placeholderWidget: SizedBox.shrink(),
                errorWidget: const SizedBox.shrink(),
                itemBuilder: (context, metadata, imageProvider, _) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: 150,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider!,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a search dialog for filtering bookmarks
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Bookmarks'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search query...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _bookmarkController.searchQuery.value = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _bookmarkController.searchQuery.value = '';
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
