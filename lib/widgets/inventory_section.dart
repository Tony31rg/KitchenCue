import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import 'inventory_row.dart';

class InventorySection extends StatelessWidget {
  const InventorySection({
    super.key,
    required this.categories,
    required this.menuItems,
    required this.draftStocks,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDraftChanged,
    required this.onSave,
    required this.onCancel,
  });

  final List<String> categories;
  final List<MenuItem> menuItems;
  final Map<String, int> draftStocks;
  final void Function(String itemId) onEdit;
  final void Function(String itemId) onIncrement;
  final void Function(String itemId) onDecrement;
  final void Function(String itemId, int value) onDraftChanged;
  final void Function(String itemId) onSave;
  final void Function(String itemId) onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Inventory Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...categories.map((cat) => _CategoryGroup(
                  category: cat,
                  items:
                      menuItems.where((item) => item.category == cat).toList(),
                  draftStocks: draftStocks,
                  onEdit: onEdit,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                  onDraftChanged: onDraftChanged,
                  onSave: onSave,
                  onCancel: onCancel,
                )),
          ],
        ),
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.category,
    required this.items,
    required this.draftStocks,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDraftChanged,
    required this.onSave,
    required this.onCancel,
  });

  final String category;
  final List<MenuItem> items;
  final Map<String, int> draftStocks;
  final void Function(String) onEdit;
  final void Function(String) onIncrement;
  final void Function(String) onDecrement;
  final void Function(String, int) onDraftChanged;
  final void Function(String) onSave;
  final void Function(String) onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(color: Color(0xFF3A3A3A), height: 1),
        const SizedBox(height: 8),
        ...items.map((item) => InventoryRow(
              item: item,
              draftStock: draftStocks[item.id],
              onEdit: () => onEdit(item.id),
              onIncrement: () => onIncrement(item.id),
              onDecrement: () => onDecrement(item.id),
              onDraftChanged: (v) => onDraftChanged(item.id, v),
              onSave: () => onSave(item.id),
              onCancel: () => onCancel(item.id),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}
