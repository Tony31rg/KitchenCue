class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;

  /// Alias so Codespace-generated widgets compile unchanged.
  int get stockCount => stock;

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
