import 'dart:collection';

import 'package:flutter/material.dart';

import '../../models/kitchen_status.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/restaurant_table.dart';

enum UserRole { waiter, chef }

class AppState extends ChangeNotifier {
  AppState();

  UserRole? userRole;
  String waiterName = '';
  KitchenStatus kitchenStatus = KitchenStatus.ready;
  int? selectedTableNumber;

  final List<MenuItem> _menuItems = _seedMenuItems();
  final List<Order> _orders = <Order>[];
  final List<RestaurantTable> _tables = _seedTables();

  UnmodifiableListView<MenuItem> get menuItems =>
      UnmodifiableListView(_menuItems);

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  UnmodifiableListView<RestaurantTable> get tables =>
      UnmodifiableListView(_tables);

  bool get isKitchenBusy => kitchenStatus.isBusy;

  List<String> get categories {
    final set = _menuItems.map((item) => item.category).toSet().toList();
    set.sort();
    return set;
  }

  void setUserRole(UserRole? role) {
    userRole = role;
    notifyListeners();
  }

  void setWaiterName(String name) {
    waiterName = name.trim();
    notifyListeners();
  }

  MenuItem? _findMenuItem(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateStock(String itemId, int newStock) {
    final index = _menuItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final clamped = newStock < 0 ? 0 : newStock;
    _menuItems[index] = _menuItems[index].copyWith(stock: clamped);
    notifyListeners();
  }

  bool decrementStock(String itemId, int quantity) {
    final item = _findMenuItem(itemId);
    if (item == null || item.stock < quantity) {
      return false;
    }
    updateStock(itemId, item.stock - quantity);
    return true;
  }

  Order? placeOrder({
    required int tableNumber,
    required Map<String, int> cart,
  }) {
    if (cart.isEmpty) return null;

    final orderItems = <OrderItem>[];
    for (final entry in cart.entries) {
      final menuItem = _findMenuItem(entry.key);
      if (menuItem == null) return null;
      if (menuItem.stock < entry.value) return null;
      orderItems.add(
        OrderItem(menuItem: menuItem, quantity: entry.value),
      );
    }

    for (final entry in cart.entries) {
      decrementStock(entry.key, entry.value);
    }

    final order = Order.create(
      tableNumber: tableNumber,
      items: orderItems,
      waiterName: waiterName.isEmpty ? 'Waiter' : waiterName,
    );

    _orders.add(order);
    notifyListeners();
    return order;
  }

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(status: status);
    notifyListeners();
  }

  void setKitchenStatus(KitchenStatus status) {
    kitchenStatus = status;
    notifyListeners();
  }

  void toggleKitchenBusy() {
    kitchenStatus = kitchenStatus == KitchenStatus.busy
        ? KitchenStatus.ready
        : KitchenStatus.busy;
    notifyListeners();
  }

  void resetAllStock(int value) {
    for (var i = 0; i < _menuItems.length; i++) {
      _menuItems[i] = _menuItems[i].copyWith(stock: value);
    }
    notifyListeners();
  }

  void addStockToAll(int value) {
    for (var i = 0; i < _menuItems.length; i++) {
      _menuItems[i] =
          _menuItems[i].copyWith(stock: _menuItems[i].stock + value);
    }
    notifyListeners();
  }

  void addMenuItem(MenuItem item) {
    _menuItems.add(item);
    notifyListeners();
  }

  String generateNewId() {
    final maxId = _menuItems
        .map((item) => int.tryParse(item.id) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    return '${maxId + 1}';
  }

  // Table management
  void selectTable(int? tableNumber) {
    selectedTableNumber = tableNumber;
    notifyListeners();
  }

  void addTable(int tableNumber, {int seats = 4}) {
    final id = 'table_$tableNumber';
    if (_tables.any((t) => t.tableNumber == tableNumber.toString())) {
      return; // Table already exists
    }
    _tables.add(RestaurantTable(
      id: id,
      tableNumber: tableNumber.toString(),
      status: TableStatus.empty,
      seats: seats,
    ));
    _tables.sort(
        (a, b) => int.parse(a.tableNumber).compareTo(int.parse(b.tableNumber)));
    notifyListeners();
  }

  void updateTableStatus(String tableNumber, TableStatus status,
      {String? orderId}) {
    final index = _tables.indexWhere((t) => t.tableNumber == tableNumber);
    if (index == -1) return;
    _tables[index] = _tables[index].copyWith(
      status: status,
      currentOrderId: orderId,
    );
    notifyListeners();
  }

  static List<RestaurantTable> _seedTables() {
    return [
      RestaurantTable(
          id: 'table_1', tableNumber: '1', status: TableStatus.empty, seats: 4),
      RestaurantTable(
          id: 'table_2', tableNumber: '2', status: TableStatus.empty, seats: 4),
      RestaurantTable(
          id: 'table_3', tableNumber: '3', status: TableStatus.empty, seats: 2),
      RestaurantTable(
          id: 'table_4', tableNumber: '4', status: TableStatus.empty, seats: 6),
      RestaurantTable(
          id: 'table_5', tableNumber: '5', status: TableStatus.empty, seats: 4),
    ];
  }

  static List<MenuItem> _seedMenuItems() {
    return const <MenuItem>[
      MenuItem(
        id: '1',
        name: 'Special Cake',
        price: 8.99,
        stock: 2,
        category: 'Desserts',
        imageUrl:
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300',
      ),
      MenuItem(
        id: '2',
        name: 'Grilled Salmon',
        price: 18.99,
        stock: 5,
        category: 'Main Course',
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=300',
      ),
      MenuItem(
        id: '3',
        name: 'Caesar Salad',
        price: 9.99,
        stock: 8,
        category: 'Salads',
        imageUrl:
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=300',
      ),
      MenuItem(
        id: '4',
        name: 'Beef Burger',
        price: 12.99,
        stock: 6,
        category: 'Main Course',
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
      ),
      MenuItem(
        id: '5',
        name: 'Pasta Carbonara',
        price: 14.99,
        stock: 4,
        category: 'Main Course',
        imageUrl:
            'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=300',
      ),
      MenuItem(
        id: '6',
        name: 'Tomato Soup',
        price: 6.99,
        stock: 10,
        category: 'Appetizers',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=300',
      ),
      MenuItem(
        id: '7',
        name: 'Chocolate Brownie',
        price: 7.99,
        stock: 3,
        category: 'Desserts',
        imageUrl:
            'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?w=300',
      ),
      MenuItem(
        id: '8',
        name: 'Greek Salad',
        price: 10.99,
        stock: 7,
        category: 'Salads',
        imageUrl:
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300',
      ),
    ];
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required this.state,
    required super.child,
  }) : super(notifier: state);

  final AppState state;

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
      throw StateError('AppStateScope not found in context');
    }
    return scope.state;
  }
}
