/// Represents a category in the restaurant menu.
class Category {
  /// Unique identifier for the category.
  final String id;

  /// Display name of the category.
  final String name;

  /// Optional icon identifier or asset path.
  final String? icon;

  Category({
    required this.id,
    required this.name,
    this.icon,
  });

  /// Factory constructor to create a Category from JSON.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }

  /// Convert Category to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
