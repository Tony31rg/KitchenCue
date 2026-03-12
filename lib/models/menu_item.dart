/// Menu Status matching PRD Section 6.1 (US-001)
/// | Status | Icon | Meaning | Display |
/// | Available | 🟢 | Ready to sell (sufficient stock) | Normal display |
/// | Low Stock | 🟡 | Running low (remaining < threshold) | Display + remaining quantity badge |
/// | 86'd / Sold Out | 🔴 | Out of stock | Greyed out + strikethrough |
/// | Limited Time | ⏰ | Today's special | Display + highlight |
enum MenuItemStatus {
  available,
  lowStock,
  soldOut,
  limitedTime,
}

extension MenuItemStatusExt on MenuItemStatus {
  String get icon {
    switch (this) {
      case MenuItemStatus.available:
        return '🟢';
      case MenuItemStatus.lowStock:
        return '🟡';
      case MenuItemStatus.soldOut:
        return '🔴';
      case MenuItemStatus.limitedTime:
        return '⏰';
    }
  }

  String get label {
    switch (this) {
      case MenuItemStatus.available:
        return 'Available';
      case MenuItemStatus.lowStock:
        return 'Low Stock';
      case MenuItemStatus.soldOut:
        return 'Sold Out';
      case MenuItemStatus.limitedTime:
        return 'Limited Time';
    }
  }

  int get colorValue {
    switch (this) {
      case MenuItemStatus.available:
        return 0xFF4CAF50; // Green
      case MenuItemStatus.lowStock:
        return 0xFFFFC107; // Yellow/Amber
      case MenuItemStatus.soldOut:
        return 0xFF9E9E9E; // Grey
      case MenuItemStatus.limitedTime:
        return 0xFF2196F3; // Blue
    }
  }

  bool get canOrder =>
      this == MenuItemStatus.available ||
      this == MenuItemStatus.lowStock ||
      this == MenuItemStatus.limitedTime;
}

/// Menu item model matching PRD Data Model (Section 10)
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
    this.is86d = false,
    this.avgPrepTime = 10,
    this.lowStockThreshold = 5,
    this.isLimitedTime = false,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;

  /// Whether item is manually 86'd (out of stock) - PRD US-002
  final bool is86d;

  /// Average preparation time in minutes - PRD Data Model
  final int avgPrepTime;

  /// Threshold for low stock warning - PRD US-001
  final int lowStockThreshold;

  /// Whether item is a limited time special
  final bool isLimitedTime;

  /// Alias so Codespace-generated widgets compile unchanged.
  int get stockCount => stock;

  /// Get menu item status based on stock and 86'd flag
  MenuItemStatus get status {
    if (is86d || stock == 0) return MenuItemStatus.soldOut;
    if (isLimitedTime) return MenuItemStatus.limitedTime;
    if (stock <= lowStockThreshold) return MenuItemStatus.lowStock;
    return MenuItemStatus.available;
  }

  /// Whether item can be ordered
  bool get isAvailable => status.canOrder;

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    bool? is86d,
    int? avgPrepTime,
    int? lowStockThreshold,
    bool? isLimitedTime,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      is86d: is86d ?? this.is86d,
      avgPrepTime: avgPrepTime ?? this.avgPrepTime,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isLimitedTime: isLimitedTime ?? this.isLimitedTime,
    );
  }
}
