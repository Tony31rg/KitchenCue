import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'stock_badge.dart';

/// A molecule widget that displays a menu item as a card.
///
/// Combines multiple atoms (StockBadge) and other widgets to create
/// a complete menu item card with image, name, price, and stock status.
/// The card is automatically dimmed (opacity 0.5) when stock is 0.
class MenuItemCard extends StatelessWidget {
  /// The menu item to display.
  final MenuItem menuItem;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: menuItem.stockCount == 0 ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Square image container
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      color: Colors.grey[300],
                    ),
                    child: menuItem.imageUrl != null
                        ? Image.network(
                            menuItem.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey[500],
                              size: 40,
                            ),
                          ),
                  ),
                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item name (bold)
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Item price
                        Text(
                          '\$${menuItem.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Stock badge in top-right corner
              Positioned(
                top: 8,
                right: 8,
                child: StockBadge(count: menuItem.stockCount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
