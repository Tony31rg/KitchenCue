import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/restaurant_table.dart';
import '../core/constants/route_constants.dart';
import 'table_card.dart';

/// A 2-column grid component displaying restaurant tables.
///
/// Shows all tables with their status and allows navigation
/// to the Order Detail View when a table is tapped.
class TableGrid extends StatelessWidget {
  /// List of restaurant tables to display.
  final List<RestaurantTable> tables;

  const TableGrid({
    super.key,
    required this.tables,
  });

  /// Handle table tap - navigate to order detail if occupied,
  /// or show option to create new order if empty.
  void _handleTableTap(BuildContext context, RestaurantTable table) {
    if (table.status == TableStatus.occupied && table.currentOrderId != null) {
      // Navigate to order detail view
      context.push(
        '${RouteConstants.orderDetail}?orderId=${table.currentOrderId}&tableNumber=${table.tableNumber}',
      );
    } else {
      // Table is empty - show option to create new order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.tableNumber} is empty. Ready for new order!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Create Order',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to order detail with new order
              context.push(
                '${RouteConstants.orderDetail}?tableNumber=${table.tableNumber}',
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tables available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return TableCard(
          table: table,
          onTap: () => _handleTableTap(context, table),
        );
      },
    );
  }
}
