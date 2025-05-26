/// Represents a folder that can contain bookmarks
class Folder {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? color;

  /// Creates a new folder
  ///
  /// [id] Unique identifier for the folder
  /// [name] Name of the folder
  /// [description] Optional description
  /// [iconName] Optional icon name
  /// [color] Optional color in hex format
  Folder({required this.id, required this.name, this.description, this.iconName, this.color});

  /// Creates a folder from JSON data
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
    );
  }

  /// Converts folder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
    };
  }

  /// Creates a copy of this folder with the specified fields replaced
  Folder copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? color,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
    );
  }
}
