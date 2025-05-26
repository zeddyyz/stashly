import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:prf/prf.dart';

import '../models/bookmark.dart';
import '../models/folder.dart';

/// Repository for handling bookmark and folder persistence
class BookmarkRepository extends GetxService {
  final Logger _logger = Logger();

  // Define Prf objects for data persistence using jsonList for type-safe lists
  late final _bookmarksPrf = Prf.jsonList<Bookmark>(
    'bookmarks',
    fromJson: (json) => Bookmark.fromJson(json),
    toJson: (bookmark) => bookmark.toJson(),
  );

  late final _foldersPrf = Prf.jsonList<Folder>(
    'folders',
    fromJson: (json) => Folder.fromJson(json),
    toJson: (folder) => folder.toJson(),
  );

  // New Prf object for offline access timestamps with json converter
  late final _lastAccessPrf = Prf.json<Map<String, DateTime>>(
    'last_access_timestamps',
    fromJson: (json) {
      final Map<String, DateTime> timestamps = {};
      final jsonMap = json;
      jsonMap.forEach((key, value) {
        timestamps[key] = DateTime.parse(value);
      });
      return timestamps;
    },
    toJson: (timestamps) {
      final Map<String, String> stringTimestamps = {};
      timestamps.forEach((key, value) {
        stringTimestamps[key] = value.toIso8601String();
      });
      return stringTimestamps;
    },
  );

  /// Initialize the repository
  Future<BookmarkRepository> init() async {
    _logger.i('BookmarkRepository initialized');
    return this;
  }

  /// Save bookmarks to persistent storage
  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    try {
      await _bookmarksPrf.set(bookmarks);
      _logger.i('Saved ${bookmarks.length} bookmarks');
    } catch (e) {
      _logger.e('Error saving bookmarks: $e');
      throw Exception('Failed to save bookmarks');
    }
  }

  /// Load bookmarks from persistent storage
  Future<List<Bookmark>> loadBookmarks() async {
    try {
      final List<Bookmark> bookmarks = await _bookmarksPrf.get() ?? [];
      _logger.i('Loaded ${bookmarks.length} bookmarks');
      // Sort bookmarks by creation date in descending order
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookmarks;
    } catch (e) {
      _logger.e('Error loading bookmarks: $e');
      return [];
    }
  }

  /// Save folders to persistent storage
  Future<void> saveFolders(List<Folder> folders) async {
    try {
      await _foldersPrf.set(folders);
      _logger.i('Saved ${folders.length} folders');
    } catch (e) {
      _logger.e('Error saving folders: $e');
      throw Exception('Failed to save folders');
    }
  }

  /// Load folders from persistent storage
  Future<List<Folder>> loadFolders() async {
    try {
      final List<Folder> folders = await _foldersPrf.get() ?? [];
      _logger.i('Loaded ${folders.length} folders');
      return folders;
    } catch (e) {
      _logger.e('Error loading folders: $e');
      return [];
    }
  }

  /// Save access timestamps for offline tracking
  Future<void> saveAccessTimestamps(Map<String, DateTime> timestamps) async {
    try {
      await _lastAccessPrf.set(timestamps);
      _logger.i('Saved ${timestamps.length} access timestamps');
    } catch (e) {
      _logger.e('Error saving access timestamps: $e');
      throw Exception('Failed to save access timestamps');
    }
  }

  /// Load access timestamps for offline tracking
  Future<Map<String, DateTime>> loadAccessTimestamps() async {
    try {
      final Map<String, DateTime> timestamps = await _lastAccessPrf.get() ?? {};
      _logger.i('Loaded ${timestamps.length} access timestamps');
      return timestamps;
    } catch (e) {
      _logger.e('Error loading access timestamps: $e');
      return {};
    }
  }

  /// Update last access timestamp for a bookmark
  Future<void> updateAccessTimestamp(String bookmarkId) async {
    try {
      final timestamps = await loadAccessTimestamps();
      timestamps[bookmarkId] = DateTime.now();
      await saveAccessTimestamps(timestamps);
      _logger.i('Updated access timestamp for bookmark $bookmarkId');
    } catch (e) {
      _logger.e('Error updating access timestamp: $e');
    }
  }

  /// Clear all access timestamps
  Future<void> clearAccessTimestamps() async {
    try {
      await _lastAccessPrf.remove();
      _logger.i('Cleared all access timestamps');
    } catch (e) {
      _logger.e('Error clearing access timestamps: $e');
    }
  }

  /// Clear all data (for testing/logout)
  Future<void> clearAllData() async {
    try {
      await _bookmarksPrf.remove();
      await _foldersPrf.remove();
      await _lastAccessPrf.remove();
      _logger.i('Cleared all bookmark data');
    } catch (e) {
      _logger.e('Error clearing data: $e');
      throw Exception('Failed to clear data');
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
