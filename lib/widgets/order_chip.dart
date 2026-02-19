import 'package:flutter/material.dart';

/// Chip showing quantity in order
class OrderChip extends StatelessWidget {
  const OrderChip(this.qty, {super.key});

  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFFFF9800), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$qty',
        style: const TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
