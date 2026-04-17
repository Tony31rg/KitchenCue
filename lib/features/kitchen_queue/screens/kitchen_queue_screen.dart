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

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final orders = state.orders.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Filter out served and cancelled orders from main view
    final activeOrders = orders
        .where((o) =>
            o.status != OrderStatus.served && o.status != OrderStatus.cancelled)
        .toList();

    final filtered = _filter == null
        ? activeOrders
        : activeOrders.where((o) => o.status == _filter).toList();

    final pending = orders.where((o) => o.status == OrderStatus.pending).length;
    final acknowledged =
        orders.where((o) => o.status == OrderStatus.acknowledged).length;
    final inProgress =
        orders.where((o) => o.status == OrderStatus.inProgress).length;
    final ready = orders.where((o) => o.status == OrderStatus.ready).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          KitchenHeader(
            totalOrders: activeOrders.length,
            pendingCount: pending + acknowledged,
            preparingCount: inProgress,
            completedCount: ready,
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
                      onStatusChange: (status) {
                        if (!state.canManageKitchenQueue) {
                          _snack('Only kitchen staff can update order status');
                          return;
                        }
                        state.updateOrderStatus(filtered[index].id, status);
                      },
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterButton(
              label: 'All',
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
              label: 'Acknowledged',
              active: _filter == OrderStatus.acknowledged,
              color: const Color(0xFF9C27B0),
              onTap: () => setState(() => _filter = OrderStatus.acknowledged),
            ),
            const SizedBox(width: 8),
            FilterButton(
              label: 'In Progress',
              active: _filter == OrderStatus.inProgress,
              color: const Color(0xFF42A5F5),
              onTap: () => setState(() => _filter = OrderStatus.inProgress),
            ),
            const SizedBox(width: 8),
            FilterButton(
              label: 'Ready',
              active: _filter == OrderStatus.ready,
              color: const Color(0xFF66BB6A),
              onTap: () => setState(() => _filter = OrderStatus.ready),
            ),
          ],
        ),
      ),
    );
  }
}
