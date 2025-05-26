import 'dart:async';

import 'package:get/get.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/bookmark.dart';
import '../repository/bookmark_repository.dart';

/// Service to handle bookmark operations including receiving shared URLs
class BookmarkService extends GetxService {
  final Logger _logger = Logger();
  final uuid = const Uuid();
  late StreamSubscription _intentSub;
  late final BookmarkRepository _repository;

  final RxList<Bookmark> bookmarks = <Bookmark>[].obs;
  final RxList<Bookmark> favorites = <Bookmark>[].obs;

  // Access timestamp tracking
  final RxMap<String, DateTime> accessTimestamps = <String, DateTime>{}.obs;

  /// The maximum number of bookmarks allowed in the free version
  static const int maxFreeBookmarks = 20;

  /// The maximum number of favorites allowed in the free version
  static const int maxFreeFavorites = 10;

  /// Initialize the bookmark service
  Future<BookmarkService> init() async {
    _logger.i('BookmarkService initialized');

    _repository = Get.find<BookmarkRepository>();

    // Load saved bookmarks
    final savedBookmarks = await _repository.loadBookmarks();
    bookmarks.assignAll(savedBookmarks);
    _updateFavorites();

    // Load access timestamps
    final timestamps = await _repository.loadAccessTimestamps();
    accessTimestamps.value = timestamps;

    // Listen to media sharing coming from outside the app while the app is in the memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        _handleSharedData(value);
      },
      onError: (err) {
        _logger.e('Error from sharing intent: $err');
      },
    );

    // Get the media sharing coming from outside the app while the app is closed
    await _checkInitialSharedData();

    return this;
  }

  /// Check if the app was opened from a sharing intent
  Future<void> _checkInitialSharedData() async {
    try {
      final List<SharedMediaFile> sharedData = await ReceiveSharingIntent.instance
          .getInitialMedia();
      if (sharedData.isNotEmpty) {
        _handleSharedData(sharedData);
        // Tell the library that we are done processing the intent
        ReceiveSharingIntent.instance.reset();
      }
    } catch (e) {
      _logger.e('Error checking initial shared data: $e');
    }
  }

  /// Handle the shared data from outside the app
  void _handleSharedData(List<SharedMediaFile> sharedData) {
    _logger.i('Received shared data: $sharedData');

    for (var file in sharedData) {
      if (file.type == SharedMediaType.url || file.type == SharedMediaType.text) {
        final String url = _extractUrl(file.path);
        if (url.isNotEmpty) {
          _addBookmarkFromUrl(url);
        }
      }
    }
  }

  /// Extract URL from shared text
  String _extractUrl(String value) {
    // Basic URL validation and extraction
    RegExp urlRegex = RegExp(
      r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[^\s]*',
      caseSensitive: false,
      multiLine: true,
    );

    final match = urlRegex.firstMatch(value);
    if (match != null) {
      return match.group(0) ?? '';
    }

    return value.trim().startsWith('http') ? value.trim() : '';
  }

  /// Add a bookmark from a shared URL
  void _addBookmarkFromUrl(String url) {
    // Check if we already have this bookmark
    if (bookmarks.any((bookmark) => bookmark.url == url)) {
      _logger.i('Bookmark already exists: $url');
      return;
    }

    // Check if we've reached the free limit
    if (!_canAddMoreBookmarks()) {
      _logger.i('Free bookmark limit reached');
      // TODO: Implement premium upsell
      return;
    }

    final newBookmark = Bookmark(
      id: uuid.v4(),
      url: url,
      title: _extractTitleFromUrl(url),
      createdAt: DateTime.now(),
      hashtags: [],
      isFavorite: false,
    );

    bookmarks.add(newBookmark);
    // Save to persistent storage
    _saveBookmarks();

    _logger.i('Added new bookmark: ${newBookmark.url}');
    // TODO: Show notification or navigate to edit page for the new bookmark
  }

  /// Extract a title from a URL
  String _extractTitleFromUrl(String url) {
    try {
      // Extract domain name as fallback title
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'New Bookmark';
    }
  }

  /// Check if more bookmarks can be added
  bool _canAddMoreBookmarks() {
    // TODO: Implement premium status check
    return bookmarks.length < maxFreeBookmarks;
  }

  /// Save bookmarks to persistent storage
  Future<void> _saveBookmarks() async {
    try {
      await _repository.saveBookmarks(bookmarks.toList());
    } catch (e) {
      _logger.e('Error saving bookmarks: $e');
    }
  }

  /// Toggle favorite status for a bookmark
  void toggleFavorite(String bookmarkId) {
    final index = bookmarks.indexWhere((b) => b.id == bookmarkId);
    if (index != -1) {
      final bookmark = bookmarks[index];
      final newFavoriteStatus = !bookmark.isFavorite;

      // Check if we're adding a favorite and at the limit
      if (newFavoriteStatus && _isFavoriteLimitReached() && !bookmark.isFavorite) {
        _logger.i('Free favorites limit reached');
        // TODO: Implement premium upsell
        return;
      }

      final updatedBookmark = bookmark.copyWith(isFavorite: newFavoriteStatus);
      bookmarks[index] = updatedBookmark;

      // Update favorites list
      _updateFavorites();

      // Save changes to persistent storage
      _saveBookmarks();
    }
  }

  /// Check if the favorites limit is reached
  bool _isFavoriteLimitReached() {
    // TODO: Implement premium status check
    return favorites.length >= maxFreeFavorites;
  }

  /// Update the favorites list based on bookmarks
  void _updateFavorites() {
    favorites.value = bookmarks.where((b) => b.isFavorite).toList();
  }

  /// Add a new bookmark
  Future<void> addBookmark(Bookmark bookmark) async {
    // Check if we already have this bookmark
    if (bookmarks.any((b) => b.url == bookmark.url)) {
      _logger.i('Bookmark already exists: ${bookmark.url}');
      return;
    }

    // Check limits
    if (!_canAddMoreBookmarks()) {
      _logger.i('Free bookmark limit reached');
      return;
    }

    // Add bookmark to list
    bookmarks.add(bookmark);

    // Update favorites list if needed
    if (bookmark.isFavorite) {
      _updateFavorites();
    }

    // Save to persistent storage
    await _saveBookmarks();

    _logger.i('Added new bookmark: ${bookmark.url}');
  }

  /// Delete a bookmark by ID
  Future<void> deleteBookmark(String bookmarkId) async {
    final index = bookmarks.indexWhere((b) => b.id == bookmarkId);
    if (index != -1) {
      final bookmark = bookmarks[index];
      bookmarks.removeAt(index);

      // Update favorites list if needed
      if (bookmark.isFavorite) {
        _updateFavorites();
      }

      // Save changes to persistent storage
      await _saveBookmarks();

      _logger.i('Deleted bookmark: ${bookmark.url}');
    }
  }

  /// Record that a bookmark was accessed
  Future<void> recordBookmarkAccess(String bookmarkId) async {
    try {
      final now = DateTime.now();
      accessTimestamps[bookmarkId] = now;
      await _repository.updateAccessTimestamp(bookmarkId);
      _logger.i('Recorded access for bookmark $bookmarkId');
    } catch (e) {
      _logger.e('Error recording bookmark access: $e');
    }
  }

  /// Check if a bookmark has been accessed recently (within the last 30 days)
  bool isBookmarkAccessedRecently(String bookmarkId) {
    final timestamp = accessTimestamps[bookmarkId];
    if (timestamp == null) return false;

    final now = DateTime.now();
    final difference = now.difference(timestamp);
    // Consider bookmarks accessed within the last 30 days as "recent"
    return difference.inDays <= 30;
  }

  /// Get all bookmarks that have been accessed recently
  List<Bookmark> getRecentlyAccessedBookmarks() {
    final recentlyAccessedIds = accessTimestamps.entries
        .where((entry) {
          final now = DateTime.now();
          final difference = now.difference(entry.value);
          return difference.inDays <= 30;
        })
        .map((entry) => entry.key)
        .toList();

    return bookmarks.where((bookmark) => recentlyAccessedIds.contains(bookmark.id)).toList();
  }

  /// Clear access timestamps
  Future<void> clearAccessTimestamps() async {
    try {
      accessTimestamps.clear();
      await _repository.clearAccessTimestamps();
      _logger.i('Cleared all access timestamps');
    } catch (e) {
      _logger.e('Error clearing access timestamps: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    bookmarks.clear();
    favorites.clear();
    accessTimestamps.clear();
    await _repository.clearAllData();
    _logger.i('Cleared all bookmark data');
  }

  /// Update an existing bookmark
  Future<void> updateBookmark(Bookmark updatedBookmark) async {
    final index = bookmarks.indexWhere((b) => b.id == updatedBookmark.id);
    if (index != -1) {
      final oldBookmark = bookmarks[index];
      bookmarks[index] = updatedBookmark;

      // Update favorites list if favorite status changed
      if (oldBookmark.isFavorite != updatedBookmark.isFavorite) {
        _updateFavorites();
      }

      // Save changes to persistent storage
      await _saveBookmarks();

      _logger.i('Updated bookmark: ${updatedBookmark.url}');
    }
  }

  @override
  void onClose() {
    _intentSub.cancel();
    super.onClose();
  }
}
