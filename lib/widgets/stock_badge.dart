import 'package:flutter/material.dart';

/// A reusable atomic widget that displays stock status as a badge.
///
/// Displays different colors and text based on the stock count:
/// - Green badge (no text) when count > 5
/// - Orange badge with "[count] LEFT" when count is between 1 and 5
/// - Dark gray badge with "SOLD OUT" when count == 0
class StockBadge extends StatelessWidget {
  /// The current stock count.
  final int count;

  const StockBadge({
    super.key,
    required this.count,
  });

  /// Determines the background color based on count.
  Color _getBackgroundColor() {
    if (count > 5) {
      return Colors.green;
    } else if (count > 0) {
      return Colors.orange;
    } else {
      return Colors.grey[700] ?? Colors.grey;
    }
  }

  /// Determines the text content based on count.
  String _getDisplayText() {
    if (count > 5) {
      return '';
    } else if (count > 0) {
      return '$count LEFT';
    } else {
      return 'SOLD OUT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getDisplayText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
