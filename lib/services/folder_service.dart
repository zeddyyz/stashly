import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../repository/bookmark_repository.dart';

/// Service to handle folder operations
class FolderService extends GetxService {
  final Logger _logger = Logger();
  final uuid = const Uuid();
  late final BookmarkRepository _repository;

  final RxList<Folder> folders = <Folder>[].obs;

  /// The maximum number of folders allowed in the free version
  static const int maxFreeFolders = 3;

  /// Initialize the folder service
  Future<FolderService> init() async {
    _logger.i('FolderService initialized');

    _repository = Get.find<BookmarkRepository>();

    // Load saved folders
    final savedFolders = await _repository.loadFolders();
    folders.assignAll(savedFolders);

    return this;
  }

  /// Save folders to persistent storage
  Future<void> _saveFolders() async {
    try {
      await _repository.saveFolders(folders.toList());
    } catch (e) {
      _logger.e('Error saving folders: $e');
      throw Exception('Failed to save folders');
    }
  }

  /// Check if more folders can be added
  bool canAddMoreFolders() {
    // TODO: Implement premium status check
    return folders.length < maxFreeFolders;
  }

  /// Add a new folder
  Future<bool> addFolder(Folder folder) async {
    try {
      // Check if folder with the same name already exists
      if (folders.any((f) => f.name.toLowerCase() == folder.name.toLowerCase())) {
        _logger.i('Folder with name ${folder.name} already exists');
        return false;
      }

      // Check if we've reached the free limit
      if (!canAddMoreFolders()) {
        _logger.i('Free folder limit reached');
        return false;
      }

      folders.add(folder);
      await _saveFolders();

      _logger.i('Added new folder: ${folder.name}');
      return true;
    } catch (e) {
      _logger.e('Error adding folder: $e');
      return false;
    }
  }

  /// Update an existing folder
  Future<bool> updateFolder(Folder updatedFolder) async {
    try {
      final index = folders.indexWhere((f) => f.id == updatedFolder.id);
      if (index == -1) {
        _logger.i('Folder not found: ${updatedFolder.id}');
        return false;
      }

      // Check if the updated name would cause a duplicate
      if (folders.any(
        (f) => f.id != updatedFolder.id && f.name.toLowerCase() == updatedFolder.name.toLowerCase(),
      )) {
        _logger.i('Another folder with name ${updatedFolder.name} already exists');
        return false;
      }

      folders[index] = updatedFolder;
      await _saveFolders();

      _logger.i('Updated folder: ${updatedFolder.name}');
      return true;
    } catch (e) {
      _logger.e('Error updating folder: $e');
      return false;
    }
  }

  /// Delete a folder by ID
  Future<bool> deleteFolder(String folderId) async {
    try {
      final index = folders.indexWhere((f) => f.id == folderId);
      if (index == -1) {
        _logger.i('Folder not found: $folderId');
        return false;
      }

      // TODO: Update associated bookmarks to remove folder reference

      folders.removeAt(index);
      await _saveFolders();

      _logger.i('Deleted folder: $folderId');
      return true;
    } catch (e) {
      _logger.e('Error deleting folder: $e');
      return false;
    }
  }

  /// Get a folder by ID
  Folder? getFolderById(String folderId) {
    try {
      return folders.firstWhere((f) => f.id == folderId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all folders
  Future<void> clearAllFolders() async {
    try {
      folders.clear();
      await _saveFolders();
      _logger.i('Cleared all folders');
    } catch (e) {
      _logger.e('Error clearing folders: $e');
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
