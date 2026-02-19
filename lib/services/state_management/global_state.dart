import 'dart:collection';

import 'package:flutter/material.dart';

import '../../models/kitchen_status.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';

enum UserRole { waiter, chef }

class AppState extends ChangeNotifier {
  AppState();

  UserRole? userRole;
  String waiterName = '';
  KitchenStatus kitchenStatus = KitchenStatus.ready;

  final List<MenuItem> _menuItems = _seedMenuItems();
  final List<Order> _orders = <Order>[];

  UnmodifiableListView<MenuItem> get menuItems =>
      UnmodifiableListView(_menuItems);

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

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

  static List<MenuItem> _seedMenuItems() {
    return const <MenuItem>[
      MenuItem(
        id: '1',
        name: 'Special Cake',
        price: 8.99,
        stock: 2,
        category: 'Desserts',
      ),
      MenuItem(
        id: '2',
        name: 'Grilled Salmon',
        price: 18.99,
        stock: 5,
        category: 'Main Course',
      ),
      MenuItem(
        id: '3',
        name: 'Caesar Salad',
        price: 9.99,
        stock: 8,
        category: 'Salads',
      ),
      MenuItem(
        id: '4',
        name: 'Beef Burger',
        price: 12.99,
        stock: 6,
        category: 'Main Course',
      ),
      MenuItem(
        id: '5',
        name: 'Pasta Carbonara',
        price: 14.99,
        stock: 4,
        category: 'Main Course',
      ),
      MenuItem(
        id: '6',
        name: 'Tomato Soup',
        price: 6.99,
        stock: 10,
        category: 'Appetizers',
      ),
      MenuItem(
        id: '7',
        name: 'Chocolate Brownie',
        price: 7.99,
        stock: 3,
        category: 'Desserts',
      ),
      MenuItem(
        id: '8',
        name: 'Greek Salad',
        price: 10.99,
        stock: 7,
        category: 'Salads',
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
