import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/menu_item.dart';
import '../../../models/order.dart';
import '../../../services/state_management/global_state.dart';

class MenuDashboardScreen extends StatefulWidget {
  const MenuDashboardScreen({super.key});

  @override
  State<MenuDashboardScreen> createState() => _MenuDashboardScreenState();
}

class _MenuDashboardScreenState extends State<MenuDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _tableCtrl = TextEditingController();
  final Map<String, int> _cart = {};
  bool _showCart = false;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tableCtrl.dispose();
    super.dispose();
  }

  int _cartCount() => _cart.values.fold(0, (s, v) => s + v);

  double _cartTotal(List<MenuItem> items) {
    double total = 0;
    for (final entry in _cart.entries) {
      final idx = items.indexWhere((i) => i.id == entry.key);
      if (idx != -1) total += items[idx].price * entry.value;
    }
    return total;
  }

  void _addToCart(MenuItem item) {
    final current = _cart[item.id] ?? 0;
    if (current >= item.stock) {
      _snack('Only ${item.stock} ${item.name} available!', isError: true);
      return;
    }
    setState(() => _cart[item.id] = current + 1);
  }

  void _removeFromCart(String itemId) {
    setState(() {
      final current = _cart[itemId] ?? 0;
      if (current <= 1) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = current - 1;
      }
    });
  }

  void _clearCart() {
    setState(() => _cart.clear());
    _snack('Cart cleared');
  }

  void _placeOrder(AppState state) {
    final tableNum = int.tryParse(_tableCtrl.text.trim());
    if (tableNum == null) {
      _snack('Please enter a table number', isError: true);
      return;
    }
    if (_cart.isEmpty) {
      _snack('Cart is empty', isError: true);
      return;
    }
    final orderItems = <OrderItem>[];
    for (final entry in _cart.entries) {
      final idx = state.menuItems.indexWhere((i) => i.id == entry.key);
      if (idx == -1) {
        _snack('Item not found', isError: true);
        return;
      }
      final item = state.menuItems[idx];
      if (item.stock < entry.value) {
        _snack('Not enough stock for ${item.name}', isError: true);
        return;
      }
      orderItems.add(OrderItem(menuItem: item, quantity: entry.value));
    }
    for (final entry in _cart.entries) {
      state.decrementStock(entry.key, entry.value);
    }
    final order = Order.create(
      tableNumber: tableNum,
      items: orderItems,
      waiterName: state.waiterName.isEmpty ? 'Waiter' : state.waiterName,
    );
    state.addOrder(order);
    setState(() {
      _cart.clear();
      _showCart = false;
    });
    context.go(RouteConstants.orderDetail, extra: order);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final menuItems = state.menuItems.toList();
    final filtered = _query.isEmpty
        ? menuItems
        : menuItems
            .where((item) =>
                item.name.toLowerCase().contains(_query.toLowerCase()) ||
                item.category.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    final categories = state.categories;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              if (state.isKitchenBusy)
                const SliverToBoxAdapter(child: _BusyBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = categories[i];
                      final catItems =
                          filtered.where((x) => x.category == cat).toList();
                      if (catItems.isEmpty) return const SizedBox.shrink();
                      return _CategorySection(
                        category: cat,
                        items: catItems,
                        cart: _cart,
                        onAdd: _addToCart,
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
          ),
          if (_showCart)
            GestureDetector(
              onTap: () => setState(() => _showCart = false),
              child: Container(color: Colors.black54),
            ),
          if (_showCart)
            _CartOverlay(
              cart: _cart,
              menuItems: menuItems,
              total: _cartTotal(menuItems),
              tableText: _tableCtrl.text,
              onAdd: (id) {
                final idx = menuItems.indexWhere((i) => i.id == id);
                if (idx != -1) _addToCart(menuItems[idx]);
              },
              onRemove: _removeFromCart,
              onClear: _clearCart,
              onClose: () => setState(() => _showCart = false),
              onPlaceOrder: () => _placeOrder(state),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppState state) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 136,
      backgroundColor: const Color(0xFF232323),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF232323),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KITCHENCUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Waiter: ${state.waiterName}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _HeaderBtn(
                    label: 'Cart',
                    icon: Icons.shopping_cart,
                    color: const Color(0xFFFF9800),
                    badge: _cartCount() > 0 ? '${_cartCount()}' : null,
                    onTap: () => setState(() => _showCart = true),
                  ),
                  const SizedBox(width: 8),
                  _HeaderBtn(
                    label: 'Logout',
                    icon: Icons.logout,
                    color: const Color(0xFF3A3A3A),
                    onTap: () {
                      state.setUserRole(null);
                      context.go(RouteConstants.login);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Search dishes...'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _tableCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Table #'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF9800)),
      ),
    );

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            if (badge != null) ...[const SizedBox(width: 6), _Badge(badge!)],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BusyBanner extends StatelessWidget {
  const _BusyBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3B2E00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kitchen is busy! Expect delays on new orders.',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
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
            mainAxisExtent: 135,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _MenuCard(
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.cartQty,
    required this.onAdd,
  });
  final MenuItem item;
  final int cartQty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final outOfStock = item.stock == 0;
    final Color badgeColor = outOfStock
        ? Colors.grey[700]!
        : item.stock <= 2
            ? Colors.red[600]!
            : item.stock <= 5
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
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    outOfStock ? 'OUT' : '${item.stock}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (cartQty > 0) ...[
                const SizedBox(height: 5),
                _CartChip(cartQty)
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CartChip extends StatelessWidget {
  const _CartChip(this.qty);
  final int qty;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFFFF9800), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$qty in cart',
        style: const TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CartOverlay extends StatelessWidget {
  const _CartOverlay({
    required this.cart,
    required this.menuItems,
    required this.total,
    required this.tableText,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onClose,
    required this.onPlaceOrder,
  });
  final Map<String, int> cart;
  final List<MenuItem> menuItems;
  final double total;
  final String tableText;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final VoidCallback onClear;
  final VoidCallback onClose;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Material(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 580,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Table ${tableText.isEmpty ? "—" : tableText}: Editing Order',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF3A3A3A), height: 1),
                Flexible(
                  child: cart.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No items in cart',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          shrinkWrap: true,
                          children: cart.entries.map((entry) {
                            final idx =
                                menuItems.indexWhere((i) => i.id == entry.key);
                            if (idx == -1) return const SizedBox.shrink();
                            final item = menuItems[idx];
                            return _CartItem(
                              item: item,
                              qty: entry.value,
                              onAdd: () => onAdd(entry.key),
                              onRemove: () => onRemove(entry.key),
                            );
                          }).toList(),
                        ),
                ),
                const Divider(color: Color(0xFF3A3A3A), height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: cart.isEmpty ? null : onClear,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('CANCEL ORDER'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: cart.isEmpty ? null : onPlaceOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('VERIFY AND SEND'),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _CartItem extends StatelessWidget {
  const _CartItem({
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
          _QtyBtn(icon: Icons.remove, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$qty',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          _QtyBtn(
            icon: Icons.add,
            onTap: item.stock > qty ? onAdd : null,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              onTap == null ? const Color(0xFF2A2A2A) : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: onTap == null ? Colors.grey[700] : Colors.white),
      ),
    );
  }
}
