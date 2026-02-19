import 'package:flutter/material.dart';

import '../../../models/order.dart';
import '../../../services/state_management/global_state.dart';
import '../../../widgets/filter_button.dart';
import '../../../widgets/kitchen_header.dart';
import '../../../widgets/kitchen_order_card.dart';

class KitchenQueueScreen extends StatefulWidget {
  const KitchenQueueScreen({super.key});

  @override
  State<KitchenQueueScreen> createState() => _KitchenQueueScreenState();
}

class _KitchenQueueScreenState extends State<KitchenQueueScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final orders = state.orders.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final filtered = _filter == null
        ? orders
        : orders.where((o) => o.status == _filter).toList();

    final pending = orders.where((o) => o.status == OrderStatus.pending).length;
    final preparing =
        orders.where((o) => o.status == OrderStatus.preparing).length;
    final completed =
        orders.where((o) => o.status == OrderStatus.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          KitchenHeader(
            totalOrders: orders.length,
            pendingCount: pending,
            preparingCount: preparing,
            completedCount: completed,
          ),
          _buildFilterBar(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No orders to display',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => KitchenOrderCard(
                      order: filtered[index],
                      onStatusChange: (status) =>
                          state.updateOrderStatus(filtered[index].id, status),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          FilterButton(
            label: 'All Orders',
            active: _filter == null,
            color: const Color(0xFFFF9800),
            onTap: () => setState(() => _filter = null),
          ),
          const SizedBox(width: 8),
          FilterButton(
            label: 'Pending',
            active: _filter == OrderStatus.pending,
            color: const Color(0xFFFF9800),
            onTap: () => setState(() => _filter = OrderStatus.pending),
          ),
          const SizedBox(width: 8),
          FilterButton(
            label: 'Preparing',
            active: _filter == OrderStatus.preparing,
            color: const Color(0xFF42A5F5),
            onTap: () => setState(() => _filter = OrderStatus.preparing),
          ),
          const SizedBox(width: 8),
          FilterButton(
            label: 'Completed',
            active: _filter == OrderStatus.completed,
            color: const Color(0xFF66BB6A),
            onTap: () => setState(() => _filter = OrderStatus.completed),
          ),
        ],
      ),
    );
  }
}
