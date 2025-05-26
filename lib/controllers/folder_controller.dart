import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../services/bookmark_service.dart';
import '../services/folder_service.dart';

/// Controller for folders UI logic
class FolderController extends GetxController {
  final FolderService _folderService = Get.find<FolderService>();
  final BookmarkService _bookmarkService = Get.find<BookmarkService>();
  final Logger _logger = Logger();
  final uuid = const Uuid();

  final RxList<Folder> folders = <Folder>[].obs;

  // UI states
  final RxBool isLoading = false.obs;
  final RxBool hasReachedFolderLimit = false.obs;

  // Selected folder for edit/view
  final Rx<Folder?> selectedFolder = Rx<Folder?>(null);

  // Maximum limits for free version
  static const int maxFreeFolders = FolderService.maxFreeFolders;

  @override
  void onInit() {
    super.onInit();

    // Initialize values from service
    _updateFromService();

    // Setup listeners
    ever(_folderService.folders, (_) => _updateFromService());

    _checkLimits();
  }

  /// Update local data from service
  void _updateFromService() {
    folders.assignAll(_folderService.folders);
    _checkLimits();
  }

  /// Check if folder limit has been reached
  void _checkLimits() {
    hasReachedFolderLimit.value = folders.length >= FolderService.maxFreeFolders;
  }

  /// Create a new folder
  Future<bool> createFolder({
    required String name,
    String? description,
    String? iconName,
    String? color,
  }) async {
    try {
      isLoading.value = true;

      // Check if we've reached the free limit
      if (folders.length >= maxFreeFolders) {
        hasReachedFolderLimit.value = true;
        return false;
      }

      final newFolder = Folder(
        id: uuid.v4(),
        name: name,
        description: description,
        iconName: iconName,
        color: color,
      );

      final result = await _folderService.addFolder(newFolder);
      return result;
    } catch (e) {
      _logger.e('Error creating folder: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing folder
  Future<bool> updateFolder({
    required String id,
    required String name,
    String? description,
    String? iconName,
    String? color,
  }) async {
    try {
      isLoading.value = true;

      // Find the existing folder
      final index = folders.indexWhere((f) => f.id == id);
      if (index == -1) return false;

      final updatedFolder = Folder(
        id: id,
        name: name,
        description: description,
        iconName: iconName,
        color: color,
      );

      final result = await _folderService.updateFolder(updatedFolder);
      return result;
    } catch (e) {
      _logger.e('Error updating folder: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a folder by ID
  Future<bool> deleteFolder(String folderId) async {
    try {
      isLoading.value = true;

      // Get bookmarks in this folder and update them to remove folder reference
      final bookmarksInFolder = _bookmarkService.bookmarks
          .where((b) => b.folderId == folderId)
          .toList();

      // Update each bookmark to remove folder reference
      for (var bookmark in bookmarksInFolder) {
        final updatedBookmark = bookmark.copyWith(folderId: null);
        await _bookmarkService.updateBookmark(updatedBookmark);
      }

      final result = await _folderService.deleteFolder(folderId);
      return result;
    } catch (e) {
      _logger.e('Error deleting folder: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a folder by ID
  Folder? getFolderById(String folderId) {
    return _folderService.getFolderById(folderId);
  }

  /// Get count of bookmarks in a folder
  int getBookmarkCountInFolder(String folderId) {
    return _bookmarkService.bookmarks.where((b) => b.folderId == folderId).length;
  }

  /// Set the selected folder
  void selectFolder(Folder folder) {
    selectedFolder.value = folder;
  }

  /// Clear selected folder
  void clearSelectedFolder() {
    selectedFolder.value = null;
  }
}
