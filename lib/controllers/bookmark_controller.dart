import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/bookmark.dart';
import '../models/folder.dart';
import '../services/bookmark_service.dart';

/// Controller for bookmarks UI logic
class BookmarkController extends GetxController {
  final BookmarkService _bookmarkService = Get.find<BookmarkService>();
  final Logger _logger = Logger();
  final uuid = const Uuid();

  final RxList<Bookmark> bookmarks = <Bookmark>[].obs;
  final RxList<Bookmark> favorites = <Bookmark>[].obs;
  final RxList<Folder> folders = <Folder>[].obs;

  // Filter states
  final RxString selectedFolderId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedHashtags = <String>[].obs;

  // UI states
  final RxBool isLoading = false.obs;
  final RxBool hasReachedBookmarkLimit = false.obs;
  final RxBool hasReachedFavoriteLimit = false.obs;
  final RxBool hasReachedFolderLimit = false.obs;

  // Maximum limits for free version
  static const int maxFreeBookmarks = BookmarkService.maxFreeBookmarks;
  static const int maxFreeFavorites = BookmarkService.maxFreeFavorites;
  static const int maxFreeFolders = 3;

  // Track offline state
  final RxBool isOfflineMode = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize values from service
    _updateFromService();

    // Setup listeners
    ever(_bookmarkService.bookmarks, (_) => _updateFromService());
    ever(_bookmarkService.favorites, (_) => _updateFavorites());

    _checkLimits();
  }

  /// Update local data from service
  void _updateFromService() {
    bookmarks.assignAll(_bookmarkService.bookmarks);
    _updateFavorites();
    _checkLimits();
  }

  /// Update favorites list
  void _updateFavorites() {
    favorites.assignAll(_bookmarkService.favorites);
  }

  /// Check if any limits have been reached
  void _checkLimits() {
    hasReachedBookmarkLimit.value = bookmarks.length >= BookmarkService.maxFreeBookmarks;
    hasReachedFavoriteLimit.value = favorites.length >= BookmarkService.maxFreeFavorites;
    // TODO: Update folder limit check when folder service is implemented
  }

  /// Toggle favorite status for a bookmark
  void toggleFavorite(String bookmarkId) {
    _bookmarkService.toggleFavorite(bookmarkId);
  }

  /// Create a new bookmark
  Future<bool> createBookmark({
    required String url,
    required String title,
    String? description,
    List<String> hashtags = const [],
    String? folderId,
    bool isFavorite = false,
  }) async {
    try {
      isLoading.value = true;

      // Check if we've reached the free limit
      if (bookmarks.length >= maxFreeBookmarks) {
        hasReachedBookmarkLimit.value = true;
        return false;
      }

      // Check if trying to add a favorite when limit reached
      if (isFavorite && favorites.length >= maxFreeFavorites) {
        hasReachedFavoriteLimit.value = true;
        return false;
      }

      final newBookmark = Bookmark(
        id: uuid.v4(),
        url: url,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        hashtags: hashtags,
        folderId: folderId,
        isFavorite: isFavorite,
      );

      await _bookmarkService.addBookmark(newBookmark);
      return true;
    } catch (e) {
      _logger.e('Error creating bookmark: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a bookmark by ID
  Future<bool> deleteBookmark(String bookmarkId) async {
    try {
      isLoading.value = true;
      await _bookmarkService.deleteBookmark(bookmarkId);
      return true;
    } catch (e) {
      _logger.e('Error deleting bookmark: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all bookmarks data
  Future<bool> clearAllData() async {
    try {
      isLoading.value = true;
      await _bookmarkService.clearAllData();
      return true;
    } catch (e) {
      _logger.e('Error clearing data: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new bookmark
  Future<bool> addBookmark({
    required String url,
    required String title,
    String? description,
    List<String> hashtags = const [],
    String? folderId,
    bool isFavorite = false,
  }) async {
    return createBookmark(
      url: url,
      title: title,
      description: description,
      hashtags: hashtags,
      folderId: folderId,
      isFavorite: isFavorite,
    );
  }

  /// Update an existing bookmark
  Future<bool> updateBookmark({
    required String id,
    required String url,
    required String title,
    String? description,
    required List<String> hashtags,
    String? folderId,
    required bool isFavorite,
  }) async {
    try {
      isLoading.value = true;

      // Find the existing bookmark
      final index = bookmarks.indexWhere((b) => b.id == id);
      if (index == -1) return false;

      // Check if making favorite and at limit
      if (isFavorite && !bookmarks[index].isFavorite && favorites.length >= maxFreeFavorites) {
        hasReachedFavoriteLimit.value = true;
        return false;
      }

      final updatedBookmark = Bookmark(
        id: id,
        url: url,
        title: title,
        description: description,
        createdAt: bookmarks[index].createdAt,
        hashtags: hashtags,
        folderId: folderId,
        isFavorite: isFavorite,
      );

      await _bookmarkService.updateBookmark(updatedBookmark);
      return true;
    } catch (e) {
      _logger.e('Error updating bookmark: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Record that a bookmark was accessed (for offline availability)
  Future<void> recordBookmarkAccess(String bookmarkId) async {
    await _bookmarkService.recordBookmarkAccess(bookmarkId);
  }

  /// Check if a bookmark has been accessed recently (cached for offline)
  bool isBookmarkOfflineAvailable(String bookmarkId) {
    return _bookmarkService.isBookmarkAccessedRecently(bookmarkId);
  }

  /// Get all recently accessed bookmarks (available offline)
  List<Bookmark> getOfflineAvailableBookmarks() {
    return _bookmarkService.getRecentlyAccessedBookmarks();
  }

  /// Get filtered bookmarks based on current filters
  List<Bookmark> getFilteredBookmarks() {
    var filtered = List<Bookmark>.from(bookmarks);

    // Filter by offline if in offline mode
    if (isOfflineMode.value) {
      filtered = filtered.where((b) => isBookmarkOfflineAvailable(b.id)).toList();
    }

    // Filter by folder
    if (selectedFolderId.isNotEmpty) {
      filtered = filtered.where((b) => b.folderId == selectedFolderId.value).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where(
            (b) =>
                b.title.toLowerCase().contains(query) ||
                (b.description?.toLowerCase().contains(query) ?? false) ||
                b.url.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter by hashtags
    if (selectedHashtags.isNotEmpty) {
      filtered = filtered
          .where((b) => selectedHashtags.every((tag) => b.hashtags.contains(tag)))
          .toList();
    }

    return filtered;
  }

  /// Toggle offline mode
  void toggleOfflineMode() {
    isOfflineMode.value = !isOfflineMode.value;
    _logger.i('Offline mode: ${isOfflineMode.value}');
  }

  /// Get all unique hashtags from bookmarks
  List<String> getAllHashtags() {
    final Set<String> allTags = {};
    for (var bookmark in bookmarks) {
      allTags.addAll(bookmark.hashtags);
    }
    return allTags.toList()..sort();
  }
}
