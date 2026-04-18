import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import 'small_action_button.dart';

class InventoryRow extends StatelessWidget {
  const InventoryRow({
    super.key,
    required this.item,
    required this.draftStock,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDraftChanged,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
    required this.onQuickRestock,
  });

  final MenuItem item;
  final int? draftStock;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final void Function(int) onDraftChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onQuickRestock;

  @override
  Widget build(BuildContext context) {
    final isEditing = draftStock != null;
    final displayStock = draftStock ?? item.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
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
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isEditing) ...[
            if (item.stock == 0) ...[
              _RestockButton(onTap: onQuickRestock),
              const SizedBox(width: 8),
            ],
            _DeleteButton(onTap: onDelete),
            const SizedBox(width: 8),
            _EditButton(onTap: onEdit),
          ] else ...[
            _StockEditor(
              displayStock: displayStock,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              onDraftChanged: onDraftChanged,
              onSave: onSave,
              onCancel: onCancel,
            ),
          ],
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Edit Stock',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF5D1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _RestockButton extends StatelessWidget {
  const _RestockButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Show Stock',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _StockEditor extends StatelessWidget {
  const _StockEditor({
    required this.displayStock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDraftChanged,
    required this.onSave,
    required this.onCancel,
  });

  final int displayStock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final void Function(int) onDraftChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmallIconButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: TextField(
            controller: TextEditingController(text: '$displayStock'),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) onDraftChanged(parsed);
            },
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SmallIconButton(icon: Icons.add, onTap: onIncrement),
        const SizedBox(width: 10),
        ActionButton(label: 'Save', color: Colors.green[700]!, onTap: onSave),
        const SizedBox(width: 6),
        ActionButton(
          label: 'Cancel',
          color: const Color(0xFF3A3A3A),
          onTap: onCancel,
        ),
      ],
    );
  }
}
