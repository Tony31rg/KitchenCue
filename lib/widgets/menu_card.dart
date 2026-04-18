import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'order_chip.dart';

/// Card displaying a menu item with image, name, price and stock
class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.item,
    required this.cartQty,
    required this.onAdd,
    this.showStock = true,
  });

  final MenuItem item;
  final int cartQty;
  final VoidCallback onAdd;
  final bool showStock;

  @override
  Widget build(BuildContext context) {
    final outOfStock = item.stock == 0;
    final lowStock = item.stock > 0 && item.stock <= 5;
    final String statusLabel = outOfStock
        ? 'OUT OF STOCK'
        : lowStock
            ? '${item.stock} LEFT'
            : 'AVAILABLE';
    final Color badgeColor = outOfStock
        ? Colors.red[700]!
        : item.stock < 5
            ? Colors.orange[700]!
            : Colors.green[700]!;

    return GestureDetector(
      onTap: outOfStock ? null : onAdd,
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameRow(
                        statusLabel,
                        badgeColor,
                        outOfStock,
                        lowStock,
                      ),
                      const Spacer(),
                      _buildPriceRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: item.imageUrl != null
          ? Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.grey, size: 28),
      ),
    );
  }

  Widget _buildNameRow(
    String statusLabel,
    Color badgeColor,
    bool outOfStock,
    bool lowStock,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (outOfStock || lowStock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFFFF9800),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        if (cartQty > 0) OrderChip(cartQty),
      ],
    );
  }
}
