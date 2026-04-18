import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/menu_item.dart';
import '../../../models/kitchen_status.dart';
import '../../../models/order.dart';
import '../../../models/restaurant_table.dart';
import '../../../services/state_management/global_state.dart';
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

  Future<void> _placeOrder(AppState state) async {
    if (!state.canPlaceOrders) {
      _snack('Only waiter accounts can place orders', isError: true);
      return;
    }
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

    final confirmed = await _confirmSendOrder(
      tableNumber: _selectedTable!,
      items: orderItems,
    );
    if (!confirmed) {
      return;
    }

    for (final entry in _cart.entries) {
      state.decrementStock(entry.key, entry.value);
    }
    final order = Order.create(
      tableNumber: _selectedTable!,
      items: orderItems,
      waiterName: state.waiterName.isEmpty ? 'Waiter' : state.waiterName,
    );

    final synced = await state.addOrderAndSync(order);
    if (!synced) {
      for (final item in orderItems) {
        final existing =
            state.menuItems.where((m) => m.id == item.menuItem.id).toList();
        if (existing.isEmpty) {
          continue;
        }
        state.updateStock(
            item.menuItem.id, existing.first.stock + item.quantity);
      }
      _snack('Failed to send order. Please retry.', isError: true);
      return;
    }

    state.updateTableStatus(_selectedTable.toString(), TableStatus.occupied,
        orderId: order.id);
    setState(() {
      _cart.clear();
      _showCart = false;
      _selectedTable = null;
    });
    _snack('Order sent to kitchen!');
    if (!mounted) {
      return;
    }
    context.go(
      '${RouteConstants.orderDetail}?orderId=${order.id}',
      extra: order,
    );
  }

  Future<bool> _confirmSendOrder({
    required int tableNumber,
    required List<OrderItem> items,
  }) async {
    final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Confirm Send To Kitchen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Table $tableNumber',
                style: const TextStyle(
                  color: Color(0xFFFFB74D),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Order Items',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    '${item.quantity} x ${item.menuItem.name}  -  \$${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send Now'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  List<Order> _openOrdersForTable(AppState state, String tableNumber) {
    final tableNo = int.tryParse(tableNumber);
    if (tableNo == null) {
      return const <Order>[];
    }
    return state.orders
        .where(
          (o) =>
              o.tableNumber == tableNo &&
              o.status != OrderStatus.served &&
              o.status != OrderStatus.cancelled,
        )
        .toList(growable: false);
  }

  Future<void> _payBillForTable(AppState state, RestaurantTable table) async {
    final openOrders = _openOrdersForTable(state, table.tableNumber);
    final total = openOrders.fold<double>(0, (sum, order) => sum + order.total);
    final itemCount =
        openOrders.fold<int>(0, (sum, order) => sum + order.totalItems);

    final shouldPay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Pay Bill - Table ${table.tableNumber}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items: $itemCount',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Confirm payment and free this table?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );

    if (shouldPay != true) {
      return;
    }

    // Billing should free table assignment, but kitchen keeps control
    // of final serve status transitions.
    state.updateTableStatus(table.tableNumber, TableStatus.empty,
        orderId: null);
    _snack('Payment received. Table ${table.tableNumber} is now free');
  }

  Widget _buildPayBillSection(AppState state) {
    final occupiedTables = state.tables
        .where((t) => t.status == TableStatus.occupied)
        .toList(growable: false)
      ..sort((a, b) =>
          int.parse(a.tableNumber).compareTo(int.parse(b.tableNumber)));

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Pay Bill',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (occupiedTables.isEmpty)
              const Text(
                'No occupied tables right now.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...occupiedTables.map((table) {
                final openOrders =
                    _openOrdersForTable(state, table.tableNumber);
                final total = openOrders.fold<double>(
                    0, (sum, order) => sum + order.total);
                final orderCount = openOrders.length;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table ${table.tableNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Open orders: $orderCount  •  Total: \$${total.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _payBillForTable(state, table),
                        icon: const Icon(Icons.point_of_sale, size: 16),
                        label: const Text('Pay Bill'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
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
              if (state.lastSyncError != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE57373)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.lastSyncError!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: state.clearLastSyncError,
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                          tooltip: 'Dismiss',
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.kitchenStatus == KitchenStatus.busy)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFFFD54F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: const Text(
                      'Kitchen is currently busy. Expect longer wait times.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (state.canPlaceOrders) _buildPayBillSection(state),
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
                        showStock: true,
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
