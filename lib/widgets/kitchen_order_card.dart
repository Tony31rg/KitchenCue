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
        return const Color(0xFFFF9800); // Orange
      case OrderStatus.acknowledged:
        return const Color(0xFF9C27B0); // Purple
      case OrderStatus.inProgress:
        return const Color(0xFF42A5F5); // Blue
      case OrderStatus.ready:
        return const Color(0xFF66BB6A); // Green
      case OrderStatus.served:
        return const Color(0xFF4CAF50); // Dark Green
      case OrderStatus.cancelled:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String get _statusLabel {
    return order.status.displayName.toUpperCase();
  }

  String get _waiterLabel {
    final name = order.waiterName.trim();
    return name.isEmpty ? 'Unknown' : name;
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
                    '${_formatTime(order.createdAt)}  •  ${_timeSince(order.createdAt)}  •  Waiter: $_waiterLabel',
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
    switch (order.status) {
      case OrderStatus.pending:
        return ElevatedButton(
          onPressed: () => onStatusChange(OrderStatus.inProgress),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Start Cooking'),
        );
      case OrderStatus.acknowledged:
        return ElevatedButton(
          onPressed: () => onStatusChange(OrderStatus.inProgress),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Start Cooking'),
        );
      case OrderStatus.inProgress:
        return ElevatedButton.icon(
          onPressed: () => onStatusChange(OrderStatus.ready),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Mark Ready'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      case OrderStatus.ready:
        return ElevatedButton.icon(
          onPressed: () => onStatusChange(OrderStatus.served),
          icon: const Icon(Icons.restaurant, size: 18),
          label: const Text('Mark Served'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      case OrderStatus.served:
      case OrderStatus.cancelled:
        return const SizedBox.shrink();
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
          // Show modifiers if present (PRD US-003)
          if (item.modifiers.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '→ ${item.modifiers.join(", ")}',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Show notes if present
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '📝 ${item.notes}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
