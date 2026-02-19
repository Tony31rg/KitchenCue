/// Represents a menu item in the restaurant.
class MenuItem {
  /// Unique identifier for the menu item.
  final String id;

  /// Name of the menu item.
  final String name;

  /// Price of the menu item.
  final double price;

  /// Current stock count for this menu item.
  final int stockCount;

  /// URL of the menu item image.
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stockCount,
    required this.imageUrl,
  });

  /// Factory constructor to create a MenuItem from JSON.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stockCount: json['stockCount'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  /// Convert MenuItem to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stockCount': stockCount,
      'imageUrl': imageUrl,
    };
  }
}