import 'package:flutter/material.dart';

import '../models/menu_item.dart';

/// A reusable atomic widget that displays stock status as a badge.
///
/// Displays different colors and text based on the stock count and 86'd status:
/// - Green badge (Available icon) when count > threshold
/// - Yellow/Orange badge with "[count] LEFT" when count is low stock
/// - Dark gray badge with "SOLD OUT" when count == 0 or is86d
/// - Blue badge for limited time items
class StockBadge extends StatelessWidget {
  /// The current stock count.
  final int count;

  /// Whether the item is 86'd (manually marked as sold out)
  final bool is86d;

  /// Low stock threshold
  final int threshold;

  /// Whether this is a limited time item
  final bool isLimitedTime;

  const StockBadge({
    super.key,
    required this.count,
    this.is86d = false,
    this.threshold = 5,
    this.isLimitedTime = false,
  });

  /// Create from MenuItem model
  factory StockBadge.fromMenuItem(MenuItem item) {
    return StockBadge(
      count: item.stock,
      is86d: item.is86d,
      threshold: item.lowStockThreshold,
      isLimitedTime: item.isLimitedTime,
    );
  }

  /// Determines the background color based on status.
  Color _getBackgroundColor() {
    if (is86d || count == 0) {
      return Colors.grey[700] ?? Colors.grey;
    }
    if (isLimitedTime) {
      return Colors.blue;
    }
    if (count <= threshold) {
      return Colors.orange;
    }
    return Colors.green;
  }

  /// Get status icon
  String _getStatusIcon() {
    if (is86d || count == 0) return '🔴';
    if (isLimitedTime) return '⏰';
    if (count <= threshold) return '🟡';
    return '🟢';
  }

  /// Determines the text content based on status.
  String _getDisplayText() {
    if (is86d) {
      return '86\'d';
    }
    if (count == 0) {
      return 'SOLD OUT';
    }
    if (isLimitedTime) {
      return 'LIMITED';
    }
    if (count <= threshold) {
      return '$count LEFT';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getStatusIcon(),
            style: const TextStyle(fontSize: 10),
          ),
          if (displayText.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
