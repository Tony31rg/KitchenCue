import 'package:flutter/material.dart';

import '../models/kitchen_status.dart';

/// Banner displayed when kitchen capacity is high or critical (PRD US-008)
class BusyBanner extends StatelessWidget {
  const BusyBanner({
    super.key,
    this.capacity = KitchenCapacity.high,
    this.estimatedWaitTime,
  });

  final KitchenCapacity capacity;
  final int? estimatedWaitTime;

  Color get _backgroundColor {
    switch (capacity) {
      case KitchenCapacity.high:
        return const Color(0xFF3B2E00); // Orange tint
      case KitchenCapacity.critical:
        return const Color(0xFF3B1E1E); // Red tint
      default:
        return const Color(0xFF3B2E00);
    }
  }

  Color get _iconColor {
    switch (capacity) {
      case KitchenCapacity.high:
        return const Color(0xFFFF9800); // Orange
      case KitchenCapacity.critical:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFFFFC107);
    }
  }

  String get _message {
    final waitText =
        estimatedWaitTime != null ? ' (~$estimatedWaitTime min wait)' : '';

    switch (capacity) {
      case KitchenCapacity.high:
        return 'Kitchen near capacity!$waitText Consider quick menu items.';
      case KitchenCapacity.critical:
        return '⚠️ Kitchen at MAX capacity!$waitText Long wait expected.';
      default:
        return 'Kitchen is busy! Expect delays on new orders.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            capacity == KitchenCapacity.critical
                ? Icons.error_outline
                : Icons.warning_amber_rounded,
            color: _iconColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: _iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Show capacity indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(capacity.colorValue),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              capacity.label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
