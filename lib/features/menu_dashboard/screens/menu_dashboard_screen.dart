import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/menu_item.dart';
import '../../../models/order.dart';
import '../../../models/restaurant_table.dart';
import '../../../services/state_management/global_state.dart';
import '../../../widgets/busy_banner.dart';
import '../../../widgets/cart_overlay.dart';
import '../../../widgets/category_section.dart';
import '../../../widgets/menu_app_bar.dart';

class MenuDashboardScreen extends StatefulWidget {
  const MenuDashboardScreen({super.key});

  @override
  State<MenuDashboardScreen> createState() => _MenuDashboardScreenState();
}

class _MenuDashboardScreenState extends State<MenuDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, int> _cart = {};
  bool _showCart = false;
  String _query = '';
  int? _selectedTable;

  @override
  void dispose() {
    _searchCtrl.dispose();
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
    if (_selectedTable == null) {
      _snack('Please select a table', isError: true);
      return;
    }
    if (_cart.isEmpty) {
      _snack('Order is empty', isError: true);
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
      tableNumber: _selectedTable!,
      items: orderItems,
      waiterName: state.waiterName.isEmpty ? 'Waiter' : state.waiterName,
    );
    state.addOrder(order);
    state.updateTableStatus(_selectedTable.toString(), TableStatus.occupied,
        orderId: order.id);
    setState(() {
      _cart.clear();
      _showCart = false;
      _selectedTable = null;
    });
    _snack('Order sent to kitchen!');
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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              MenuAppBar(
                state: state,
                searchController: _searchCtrl,
                onSearchChanged: (v) => setState(() => _query = v),
                cartCount: _cartCount(),
                onCartTap: () => setState(() => _showCart = true),
              ),
              if (state.isKitchenBusy)
                const SliverToBoxAdapter(child: BusyBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = state.categories[i];
                      final catItems =
                          filtered.where((x) => x.category == cat).toList();
                      if (catItems.isEmpty) return const SizedBox.shrink();
                      return CategorySection(
                        category: cat,
                        items: catItems,
                        cart: _cart,
                        onAdd: _addToCart,
                      );
                    },
                    childCount: state.categories.length,
                  ),
                ),
              ),
            ],
          ),
          if (_showCart) ...[
            GestureDetector(
              onTap: () => setState(() => _showCart = false),
              child: Container(color: Colors.black54),
            ),
            CartOverlay(
              cart: _cart,
              menuItems: menuItems,
              total: _cartTotal(menuItems),
              tables: state.tables.toList(),
              selectedTable: _selectedTable,
              onSelectTable: (t) => setState(() => _selectedTable = t),
              onAddTable: (num) {
                state.addTable(num);
                setState(() => _selectedTable = num);
              },
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
        ],
      ),
    );
  }
}
