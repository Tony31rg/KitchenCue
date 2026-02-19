import 'package:flutter/material.dart';
import '../models/restaurant_table.dart';

/// A card component representing a restaurant table.
///
/// Displays the table number and status with color-coded background.
/// Green indicates the table is Empty, Red indicates Occupied.
class TableCard extends StatelessWidget {
  /// The restaurant table to display.
  final RestaurantTable table;

  /// Callback function when the card is tapped.
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
  });

  /// Get the background color based on table status.
  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.empty:
        return const Color(0xFF4CAF50); // Green
      case TableStatus.occupied:
        return const Color(0xFFF44336); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _getStatusColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Table icon
                const Icon(
                  Icons.table_restaurant,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                // Table number
                Text(
                  'Table ${table.tableNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Status text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    table.status.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Seats info
                const SizedBox(height: 8),
                Text(
                  '${table.seats} seats',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
