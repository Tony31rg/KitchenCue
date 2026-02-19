import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../models/restaurant_table.dart';
import '../../../widgets/table_grid.dart';

/// Table/Menu Dashboard Screen (Waiter)
/// Displays restaurant tables with their current status.
/// Waiters use this screen to view table availability and manage orders.
class MenuDashboardScreen extends StatefulWidget {
  const MenuDashboardScreen({super.key});

  @override
  State<MenuDashboardScreen> createState() => _MenuDashboardScreenState();
}

class _MenuDashboardScreenState extends State<MenuDashboardScreen> {
  /// Mock restaurant tables data
  late List<RestaurantTable> _tables;

  @override
  void initState() {
    super.initState();
    _initializeMockTables();
  }

  /// Initialize mock table data for demonstration
  void _initializeMockTables() {
    _tables = [
      RestaurantTable(
        id: '1',
        tableNumber: '1',
        status: TableStatus.empty,
        seats: 4,
      ),
      RestaurantTable(
        id: '2',
        tableNumber: '2',
        status: TableStatus.occupied,
        seats: 2,
        currentOrderId: 'order_001',
      ),
      RestaurantTable(
        id: '3',
        tableNumber: '3',
        status: TableStatus.occupied,
        seats: 6,
        currentOrderId: 'order_002',
      ),
      RestaurantTable(
        id: '4',
        tableNumber: '4',
        status: TableStatus.empty,
        seats: 4,
      ),
      RestaurantTable(
        id: '5',
        tableNumber: '5',
        status: TableStatus.empty,
        seats: 2,
      ),
      RestaurantTable(
        id: '6',
        tableNumber: '6',
        status: TableStatus.occupied,
        seats: 8,
        currentOrderId: 'order_003',
      ),
      RestaurantTable(
        id: '7',
        tableNumber: '7',
        status: TableStatus.empty,
        seats: 4,
      ),
      RestaurantTable(
        id: '8',
        tableNumber: '8',
        status: TableStatus.occupied,
        seats: 4,
        currentOrderId: 'order_004',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiter Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0072E3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tables',
            onPressed: () {
              setState(() {
                // Refresh table data
                _initializeMockTables();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tables refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.go(RouteConstants.login);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Status Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator(
                  'Empty',
                  _tables.where((t) => t.status == TableStatus.empty).length,
                  const Color(0xFF4CAF50),
                ),
                _buildStatusIndicator(
                  'Occupied',
                  _tables.where((t) => t.status == TableStatus.occupied).length,
                  const Color(0xFFF44336),
                ),
                _buildStatusIndicator(
                  'Total',
                  _tables.length,
                  const Color(0xFF0072E3),
                ),
              ],
            ),
          ),
          // Table Grid
          Expanded(
            child: TableGrid(tables: _tables),
          ),
        ],
      ),
    );
  }

  /// Build status indicator widget
  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}