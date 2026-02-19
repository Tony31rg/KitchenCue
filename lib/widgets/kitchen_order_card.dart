import 'package:flutter/material.dart';

import '../models/order.dart';

class KitchenOrderCard extends StatelessWidget {
  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.onStatusChange,
  });

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

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$h:$min:$sec $period';
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
          _buildHeader(),
          const SizedBox(height: 14),
          _buildItemChips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  const Icon(Icons.access_time, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(order.createdAt)}  •  ${_timeSince(order.createdAt)}  •  Waiter: ${order.waiterName}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    if (order.status == OrderStatus.pending) {
      return ElevatedButton(
        onPressed: () => onStatusChange(OrderStatus.preparing),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Start Preparing'),
      );
    } else if (order.status == OrderStatus.preparing) {
      return ElevatedButton.icon(
        onPressed: () => onStatusChange(OrderStatus.completed),
        icon: const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Mark Complete'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF66BB6A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildItemChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: order.items.map((item) => _OrderItemChip(item: item)).toList(),
    );
  }
}

class _OrderItemChip extends StatelessWidget {
  const _OrderItemChip({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.18),
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
    );
  }
}
