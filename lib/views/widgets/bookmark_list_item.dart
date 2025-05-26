import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_context_extension.dart';
import '../../models/bookmark.dart';

/// Card widget to display a bookmark
class BookmarkListItem extends StatelessWidget {
  /// The bookmark to display
  final Bookmark bookmark;

  /// Callback when favorite button is pressed
  final Function(String) onToggleFavorite;

  /// Callback when the card is tapped
  final Function(String) onTap;

  /// Creates a new BookmarkListItem
  const BookmarkListItem({
    required this.bookmark,
    required this.onToggleFavorite,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onTap(bookmark.id),
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
                    onPressed: () => onToggleFavorite(bookmark.id),
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
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(bookmark.getFormattedDate(), style: context.textTheme.bodySmall),
                  if (bookmark.hashtags.isNotEmpty)
                    Flexible(
                      child: Text(
                        bookmark.hashtags.map((tag) => '#$tag').join(' '),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
