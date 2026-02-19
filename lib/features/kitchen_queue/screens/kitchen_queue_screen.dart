import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/order.dart';
import '../../../services/state_management/global_state.dart';

class KitchenQueueScreen extends StatefulWidget {
  const KitchenQueueScreen({super.key});

  @override
  State<KitchenQueueScreen> createState() => _KitchenQueueScreenState();
}

class _KitchenQueueScreenState extends State<KitchenQueueScreen> {
  // null = all
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
          // Header
          Container(
            color: const Color(0xFF232323),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KITCHENCUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Kitchen Admin',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    _HeaderBtn(
                      label: 'Kitchen Settings',
                      icon: Icons.settings,
                      color: const Color(0xFF2E7D32),
                      onTap: () => context.go(RouteConstants.kitchenStatus),
                    ),
                    const SizedBox(width: 8),
                    _HeaderBtn(
                      label: 'Logout',
                      icon: Icons.logout,
                      color: const Color(0xFF3A3A3A),
                      onTap: () {
                        state.setUserRole(null);
                        context.go(RouteConstants.login);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats bar
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: 'Total',
                            value: orders.length,
                            color: const Color(0xFF2A2A2A),
                            textColor: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatCard(
                            label: 'Pending',
                            value: pending,
                            color: const Color(0xFF3B2200),
                            textColor: const Color(0xFFFF9800))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatCard(
                            label: 'Preparing',
                            value: preparing,
                            color: const Color(0xFF0D2B4E),
                            textColor: const Color(0xFF42A5F5))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatCard(
                            label: 'Completed',
                            value: completed,
                            color: const Color(0xFF1B3A1F),
                            textColor: const Color(0xFF66BB6A))),
                  ],
                ),
              ],
            ),
          ),
          // Filter chips
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _FilterBtn(
                    label: 'All Orders',
                    active: _filter == null,
                    color: const Color(0xFFFF9800),
                    onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterBtn(
                    label: 'Pending',
                    active: _filter == OrderStatus.pending,
                    color: const Color(0xFFFF9800),
                    onTap: () => setState(() => _filter = OrderStatus.pending)),
                const SizedBox(width: 8),
                _FilterBtn(
                    label: 'Preparing',
                    active: _filter == OrderStatus.preparing,
                    color: const Color(0xFF42A5F5),
                    onTap: () =>
                        setState(() => _filter = OrderStatus.preparing)),
                const SizedBox(width: 8),
                _FilterBtn(
                    label: 'Completed',
                    active: _filter == OrderStatus.completed,
                    color: const Color(0xFF66BB6A),
                    onTap: () =>
                        setState(() => _filter = OrderStatus.completed)),
              ],
            ),
          ),
          // Orders list
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
                    itemBuilder: (context, index) => _OrderCard(
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
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });
  final String label;
  final int value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('$value',
              style: TextStyle(
                  color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  const _FilterBtn({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onStatusChange});
  final Order order;
  final void Function(OrderStatus) onStatusChange;

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800);
      case OrderStatus.preparing:
        return const Color(0xFF42A5F5);
      case OrderStatus.completed:
        return const Color(0xFF66BB6A);
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.completed:
        return 'COMPLETED';
    }
  }

  String _timeSince(DateTime dt) {
    final secs = DateTime.now().difference(dt).inSeconds;
    if (secs < 60) return '${secs}s ago';
    final mins = secs ~/ 60;
    if (mins < 60) return '${mins}m ago';
    return '${mins ~/ 60}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Table ${order.tableNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(order.createdAt)}  •  ${_timeSince(order.createdAt)}  •  Waiter: ${order.waiterName}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action button
              if (order.status == OrderStatus.pending)
                ElevatedButton(
                  onPressed: () => onStatusChange(OrderStatus.preparing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Start Preparing'),
                )
              else if (order.status == OrderStatus.preparing)
                ElevatedButton.icon(
                  onPressed: () => onStatusChange(OrderStatus.completed),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: order.items
                .map(
                  (item) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.menuItem.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF9800).withValues(alpha: 0.18),
                            border: Border.all(color: const Color(0xFFFF9800)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$h:$min:$sec $period';
  }
}
