import 'package:jiffy/jiffy.dart';

/// Represents a bookmark in the application
class Bookmark {
  final String id;
  final String url;
  final String title;
  final String? description;
  final DateTime createdAt;
  final List<String> hashtags;
  final String? folderId;
  final bool isFavorite;

  /// Creates a new bookmark
  ///
  /// [id] Unique identifier for the bookmark
  /// [url] The URL of the bookmark
  /// [title] Title of the bookmark
  /// [description] Optional description
  /// [createdAt] When the bookmark was created
  /// [hashtags] List of hashtags associated with the bookmark
  /// [folderId] Optional ID of the folder it belongs to
  /// [isFavorite] Whether the bookmark is marked as favorite
  Bookmark({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    required this.createdAt,
    required this.hashtags,
    this.folderId,
    required this.isFavorite,
  });

  /// Creates a bookmark from JSON data
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hashtags: List<String>.from(json['hashtags'] as List),
      folderId: json['folderId'] as String?,
      isFavorite: json['isFavorite'] as bool,
    );
  }

  /// Converts bookmark to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'folderId': folderId,
      'isFavorite': isFavorite,
    };
  }

  /// Creates a copy of this bookmark with the specified fields replaced
  Bookmark copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    DateTime? createdAt,
    List<String>? hashtags,
    String? folderId,
    bool? isFavorite,
  }) {
    return Bookmark(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      folderId: folderId ?? this.folderId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Returns a formatted created date string
  String getFormattedDate() {
    return Jiffy.parseFromDateTime(createdAt).format(pattern: 'MMM dd, yyyy');
  }
}
