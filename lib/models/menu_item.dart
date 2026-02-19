class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
    );
  }
}
