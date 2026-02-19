import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'qty_button.dart';

/// Single item row in the cart
class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.item,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final MenuItem item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$qty x ${item.name}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style:
                      const TextStyle(color: Color(0xFFFF9800), fontSize: 12),
                ),
              ],
            ),
          ),
          QtyButton(icon: Icons.remove, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$qty',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          QtyButton(
            icon: Icons.add,
            onTap: item.stock > qty ? onAdd : null,
          ),
        ],
      ),
    );
  }
}
