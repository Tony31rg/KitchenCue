import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'menu_card.dart';

/// Section displaying a category with its menu items in a grid
class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.cart,
    required this.onAdd,
  });

  final String category;
  final List<MenuItem> items;
  final Map<String, int> cart;
  final void Function(MenuItem) onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisExtent: 150,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => MenuCard(
            item: items[index],
            cartQty: cart[items[index].id] ?? 0,
            onAdd: () => onAdd(items[index]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
