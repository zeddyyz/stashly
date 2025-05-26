import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bookmark_controller.dart';

/// Widget to indicate if a bookmark is available offline
class OfflineAvailableBadge extends StatelessWidget {
  /// Creates a new OfflineAvailableBadge widget
  ///
  /// [bookmarkId] The ID of the bookmark to check
  const OfflineAvailableBadge({required this.bookmarkId, super.key});

  /// The bookmark ID to check for offline availability
  final String bookmarkId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarkController>();

    // Check if bookmark is available offline
    final isAvailable = controller.isBookmarkOfflineAvailable(bookmarkId);

    // Don't show anything if not available offline
    if (!isAvailable) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.offline_pin, size: 12, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
