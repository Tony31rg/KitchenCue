import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Order Detail View Screen
/// Displays order details for a specific table and allows order management
class OrderDetailScreen extends StatelessWidget {
  /// Optional order ID if viewing existing order
  final String? orderId;

  /// Table number for this order
  final String? tableNumber;

  const OrderDetailScreen({
    super.key,
    this.orderId,
    this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isNewOrder = orderId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewOrder ? 'New Order' : 'Order Details',
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0072E3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isNewOrder ? Icons.add_shopping_cart : Icons.receipt_long,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              if (tableNumber != null)
                Text(
                  'Table $tableNumber',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0072E3),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                isNewOrder ? 'Create New Order' : 'Order #$orderId',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order management interface coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072E3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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