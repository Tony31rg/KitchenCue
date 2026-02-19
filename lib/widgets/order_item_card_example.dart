import 'package:flutter/material.dart';
import '../models/order_item.dart';
import 'order_item_card.dart';

/// Mock data and usage examples for OrderItemCard component.
class OrderItemCardExample extends StatelessWidget {
  const OrderItemCardExample({super.key});

  /// Generate mock order items for demonstration.
  static List<OrderItem> getMockOrderItems() {
    return [
      OrderItem(
        id: '1',
        dishName: 'Special Lava Cake',
        quantity: 2,
        tableNumber: '5',
        status: OrderStatus.urgent,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      OrderItem(
        id: '2',
        dishName: 'Grilled Salmon with Asparagus',
        quantity: 1,
        tableNumber: '12',
        status: OrderStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      OrderItem(
        id: '3',
        dishName: 'Margherita Pizza',
        quantity: 3,
        tableNumber: '7',
        status: OrderStatus.ready,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      OrderItem(
        id: '4',
        dishName: 'Caesar Salad with Grilled Chicken',
        quantity: 2,
        tableNumber: '3',
        status: OrderStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mockOrders = getMockOrderItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Items - RestoSync'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return OrderItemCard(
            orderItem: mockOrders[index],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped: ${mockOrders[index].dishName}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Simple widget showing a single OrderItemCard example.
class OrderItemCardSimpleExample extends StatelessWidget {
  const OrderItemCardSimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final orderItem = OrderItem(
      id: '1',
      dishName: 'Special Lava Cake',
      quantity: 2,
      tableNumber: '5',
      status: OrderStatus.urgent,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: OrderItemCard(
          orderItem: orderItem,
          onTap: () {
            print('Card tapped!');
          },
        ),
      ),
    );
  }
}
