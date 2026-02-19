import 'package:flutter/material.dart';
import '../models/order_item.dart';

/// RestoSync Theme Colors
class RestoSyncTheme {
  static const Color primary = Color(0xFF0072E3); // Blue
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color statusReady = Color(0xFF4CAF50); // Green
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusUrgent = Color(0xFFF44336); // Red
}

/// A professional order item card component for a restaurant management app.
///
/// Displays order details including dish name, quantity, table number,
/// current status with color-coded badge, and relative timestamp.
/// Follows the RestoSync design system with modern styling.
class OrderItemCard extends StatelessWidget {
  /// The order item to display.
  final OrderItem orderItem;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  const OrderItemCard({
    super.key,
    required this.orderItem,
    this.onTap,
  });

  /// Get status badge color based on order status.
  Color _getStatusColor() {
    switch (orderItem.status) {
      case OrderStatus.ready:
        return RestoSyncTheme.statusReady;
      case OrderStatus.pending:
        return RestoSyncTheme.statusPending;
      case OrderStatus.urgent:
        return RestoSyncTheme.statusUrgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: RestoSyncTheme.lightGrey,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(
              color: RestoSyncTheme.lightGrey,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Dish name and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      orderItem.dishName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      orderItem.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Middle: Quantity and Table info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: RestoSyncTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'x${orderItem.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: RestoSyncTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Table Number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Table',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: RestoSyncTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'T${orderItem.tableNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: RestoSyncTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Footer: Timestamp
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  orderItem.getRelativeTime(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
