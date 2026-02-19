import 'menu_item.dart';

enum OrderStatus { pending, preparing, completed }

class OrderItem {
  const OrderItem({required this.menuItem, required this.quantity});

  final MenuItem menuItem;
  final int quantity;

  double get lineTotal => menuItem.price * quantity;
}

class Order {
  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.waiterName,
  });

  final String id;
  final int tableNumber;
  final List<OrderItem> items;
  final DateTime createdAt;
  OrderStatus status;
  final String waiterName;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  Order copyWith({
    String? id,
    int? tableNumber,
    List<OrderItem>? items,
    DateTime? createdAt,
    OrderStatus? status,
    String? waiterName,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      waiterName: waiterName ?? this.waiterName,
    );
  }

  static Order create({
    required int tableNumber,
    required List<OrderItem> items,
    required String waiterName,
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
    );
  }
}
