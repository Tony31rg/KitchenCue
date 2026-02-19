/// Enum for order item status states.
enum OrderStatus {
  pending,
  ready,
  urgent,
}

/// Extension to map OrderStatus to display strings and colors.
extension OrderStatusExt on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.urgent:
        return 'Urgent';
    }
  }
}

/// Represents an order item in the kitchen/table management system.
class OrderItem {
  /// Unique identifier for the order item.
  final String id;

  /// Name of the dish.
  final String dishName;

  /// Quantity ordered.
  final int quantity;

  /// Table number where the order is for.
  final String tableNumber;

  /// Current status of the order.
  final OrderStatus status;

  /// Timestamp when the order was placed (DateTime).
  final DateTime timestamp;

  OrderItem({
    required this.id,
    required this.dishName,
    required this.quantity,
    required this.tableNumber,
    required this.status,
    required this.timestamp,
  });

  /// Get relative time string (e.g., "Ordered 5 mins ago").
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ordered just now';
    } else if (difference.inMinutes < 60) {
      return 'Ordered ${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return 'Ordered ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Ordered ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  /// Factory constructor to create an OrderItem from JSON.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      dishName: json['dishName'] as String,
      quantity: json['quantity'] as int,
      tableNumber: json['tableNumber'] as String,
      status: OrderStatus.values.byName(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert OrderItem to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dishName': dishName,
      'quantity': quantity,
      'tableNumber': tableNumber,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
