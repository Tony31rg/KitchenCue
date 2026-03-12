import 'menu_item.dart';

/// Order status matching PRD Section 6.2 (US-005)
/// | Status | Icon | Meaning |
/// | Pending | 📝 | Waiting for kitchen to receive |
/// | Acknowledged | 👀 | Kitchen received, in queue |
/// | In Progress | 🔥 | Being prepared |
/// | Ready | 🔔 | Ready to serve |
/// | Served | ✅ | Already served |
/// | Cancelled | ❌ | Cancelled |
enum OrderStatus {
  pending,
  acknowledged,
  inProgress,
  ready,
  served,
  cancelled,
}

extension OrderStatusExt on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.acknowledged:
        return 'Acknowledged';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return '📝';
      case OrderStatus.acknowledged:
        return '👀';
      case OrderStatus.inProgress:
        return '🔥';
      case OrderStatus.ready:
        return '🔔';
      case OrderStatus.served:
        return '✅';
      case OrderStatus.cancelled:
        return '❌';
    }
  }

  /// Whether the order can still be modified (only pending orders per PRD US-004)
  bool get canModify => this == OrderStatus.pending;

  /// Whether the order can be cancelled
  bool get canCancel =>
      this == OrderStatus.pending || this == OrderStatus.acknowledged;
}

class OrderItem {
  const OrderItem({
    required this.menuItem,
    required this.quantity,
    this.modifiers = const [],
    this.course = 1,
    this.notes,
  });

  final MenuItem menuItem;
  final int quantity;

  /// Modifiers like "No MSG", "Extra spicy", etc. (PRD US-003)
  final List<String> modifiers;

  /// Course number for split courses (PRD US-003)
  final int course;

  /// Special notes
  final String? notes;

  double get lineTotal => menuItem.price * quantity;

  OrderItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    List<String>? modifiers,
    int? course,
    String? notes,
  }) {
    return OrderItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers ?? this.modifiers,
      course: course ?? this.course,
      notes: notes ?? this.notes,
    );
  }
}

class Order {
  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.waiterName,
    this.acknowledgedAt,
    this.readyAt,
    this.servedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.notes,
  });

  final String id;
  final int tableNumber;
  final List<OrderItem> items;
  final DateTime createdAt;
  OrderStatus status;
  final String waiterName;

  /// Timestamp when kitchen acknowledged (PRD Data Model)
  final DateTime? acknowledgedAt;

  /// Timestamp when ready to serve
  final DateTime? readyAt;

  /// Timestamp when served
  final DateTime? servedAt;

  /// Timestamp when cancelled
  final DateTime? cancelledAt;

  /// Cancellation reason (required per PRD US-004)
  final String? cancellationReason;

  /// Order-level notes
  final String? notes;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Estimated wait time based on items (simplified calculation)
  int get estimatedWaitMinutes {
    int total = 0;
    for (final item in items) {
      total += item.menuItem.avgPrepTime * item.quantity;
    }
    return total;
  }

  Order copyWith({
    String? id,
    int? tableNumber,
    List<OrderItem>? items,
    DateTime? createdAt,
    OrderStatus? status,
    String? waiterName,
    DateTime? acknowledgedAt,
    DateTime? readyAt,
    DateTime? servedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      waiterName: waiterName ?? this.waiterName,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      readyAt: readyAt ?? this.readyAt,
      servedAt: servedAt ?? this.servedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
    );
  }

  static Order create({
    required int tableNumber,
    required List<OrderItem> items,
    required String waiterName,
    String? notes,
  }) {
    final now = DateTime.now();
    final generatedId =
        'order-${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch % 1000}';

    return Order(
      id: generatedId,
      tableNumber: tableNumber,
      items: items,
      createdAt: now,
      status: OrderStatus.pending,
      waiterName: waiterName,
      notes: notes,
    );
  }
}
