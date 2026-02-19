import 'package:flutter/material.dart';
import '../models/restaurant_table.dart';

/// Horizontal scrollable table selector with add button
class TableSelector extends StatelessWidget {
  const TableSelector({
    super.key,
    required this.tables,
    required this.selectedTable,
    required this.onSelectTable,
    required this.onAddTable,
  });

  final List<RestaurantTable> tables;
  final int? selectedTable;
  final void Function(int) onSelectTable;
  final VoidCallback onAddTable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.table_restaurant, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Select Table',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAddTable,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('New Table',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return _TableChip(
                table: table,
                isSelected:
                    selectedTable == (int.tryParse(table.tableNumber) ?? 0),
                onTap: () =>
                    onSelectTable(int.tryParse(table.tableNumber) ?? 0),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableChip extends StatelessWidget {
  const _TableChip({
    required this.table,
    required this.isSelected,
    required this.onTap,
  });

  final RestaurantTable table;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.status == TableStatus.occupied;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: isOccupied ? null : onTap,
        child: Container(
          width: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF9800)
                : isOccupied
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF9800)
                  : isOccupied
                      ? Colors.red[400]!
                      : const Color(0xFF3A3A3A),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.tableNumber,
                style: TextStyle(
                  color: isOccupied ? Colors.grey : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isOccupied ? 'Busy' : '${table.seats}p',
                style: TextStyle(
                  color: isOccupied ? Colors.red[300] : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
