import 'dart:collection';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/kitchen_status.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/restaurant_table.dart';
import '../../models/user_role.dart';
import '../firebase/firestore_sync_service.dart';

class AppState extends ChangeNotifier {
  AppState();

  UserRole? userRole;
  String waiterName = '';
  String currentStaffId = '';
  String sessionToken = '';

  bool get canManageStock => userRole?.canManageStock ?? false;
  bool get canManageKitchenQueue => userRole == UserRole.kitchen;
  bool get canPlaceOrders => userRole == UserRole.waiter;

  // Kitchen capacity system (PRD Section 6.4)
  KitchenCapacity kitchenCapacity = KitchenCapacity.low;
  KitchenCapacityParams kitchenParams = const KitchenCapacityParams();

  // Keep legacy for backwards compatibility
  @Deprecated('Use kitchenCapacity instead')
  KitchenStatus kitchenStatus = KitchenStatus.ready;

  int? selectedTableNumber;

  final List<MenuItem> _menuItems = _seedMenuItems();
  final List<Order> _orders = <Order>[];
  final List<RestaurantTable> _tables = _seedTables();

  FirestoreSyncService? _syncService;
  StreamSubscription<List<MenuItem>>? _menuSubscription;
  StreamSubscription<List<Order>>? _orderSubscription;
  StreamSubscription<bool>? _busySubscription;
  bool _syncingFromRemote = false;
  bool _syncInitialized = false;

  UnmodifiableListView<MenuItem> get menuItems =>
      UnmodifiableListView(_menuItems);

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  UnmodifiableListView<RestaurantTable> get tables =>
      UnmodifiableListView(_tables);

  /// Whether kitchen is busy (high or critical capacity)
  bool get isKitchenBusy => kitchenCapacity.isBusy;

  /// Get current capacity percentage
  double get capacityPercent {
    final pendingOrders = _orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.acknowledged ||
            o.status == OrderStatus.inProgress)
        .toList();

    int totalPrepTime = 0;
    for (final order in pendingOrders) {
      for (final item in order.items) {
        totalPrepTime += item.menuItem.avgPrepTime * item.quantity;
      }
    }
    return kitchenParams.calculateCapacityPercent(
        pendingOrders.length, totalPrepTime);
  }

  /// Estimated wait time in minutes
  int get estimatedWaitTime {
    final pendingCount = _orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.acknowledged ||
            o.status == OrderStatus.inProgress)
        .length;
    return kitchenParams.estimateWaitTime(pendingCount);
  }

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

  void setSession({
    required String staffId,
    required String token,
  }) {
    currentStaffId = staffId;
    sessionToken = token;
    notifyListeners();
  }

  void clearSession() {
    stopRemoteSync();
    userRole = null;
    waiterName = '';
    currentStaffId = '';
    sessionToken = '';
    notifyListeners();
  }

  Future<void> initializeRemoteSync({
    FirestoreSyncService? service,
  }) async {
    if (_syncInitialized) {
      return;
    }

    _syncService = service ?? FirestoreSyncService();
    await _syncService!.ensureMenuSeeded(_menuItems);
    await _syncService!.ensureKitchenConfig();

    _menuSubscription = _syncService!.watchMenuItems().listen((items) {
      _syncingFromRemote = true;
      _menuItems
        ..clear()
        ..addAll(items);
      _syncingFromRemote = false;
      notifyListeners();
    });

    _orderSubscription = _syncService!.watchOrders().listen((orders) {
      _syncingFromRemote = true;
      _orders
        ..clear()
        ..addAll(orders);
      _recalculateCapacity();
      _syncingFromRemote = false;
      notifyListeners();
    });

    _busySubscription = _syncService!.watchKitchenBusyMode().listen((isBusy) {
      _syncingFromRemote = true;
      kitchenStatus = isBusy ? KitchenStatus.busy : KitchenStatus.ready;
      _syncingFromRemote = false;
      notifyListeners();
    });

    _syncInitialized = true;
  }

  void stopRemoteSync() {
    if (!_syncInitialized) {
      return;
    }

    unawaited(_menuSubscription?.cancel());
    unawaited(_orderSubscription?.cancel());
    unawaited(_busySubscription?.cancel());
    _menuSubscription = null;
    _orderSubscription = null;
    _busySubscription = null;
    _syncService = null;
    _syncInitialized = false;
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

    if (!_syncingFromRemote) {
      unawaited(_syncService?.updateMenuStock(
        itemId: itemId,
        stock: clamped,
        is86d: _menuItems[index].is86d,
      ));
    }
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
    _recalculateCapacity();
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(
        _syncService?.submitOrder(
          tableNumber: order.tableNumber,
          items: order.items
              .map(
                (item) => {
                  'menuItemId': item.menuItem.id,
                  'name': item.menuItem.name,
                  'price': item.menuItem.price,
                  'quantity': item.quantity,
                  'modifiers': item.modifiers,
                  'course': item.course,
                  'notes': item.notes,
                },
              )
              .toList(growable: false),
        ),
      );
    }
  }

  /// Update order status with appropriate timestamps (PRD US-005, US-007)
  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final now = DateTime.now();
    Order updated = _orders[index].copyWith(status: status);

    // Set appropriate timestamp based on status
    switch (status) {
      case OrderStatus.acknowledged:
        updated = updated.copyWith(acknowledgedAt: now);
        break;
      case OrderStatus.ready:
        updated = updated.copyWith(readyAt: now);
        break;
      case OrderStatus.served:
        updated = updated.copyWith(servedAt: now);
        break;
      default:
        break;
    }

    _orders[index] = updated;
    _recalculateCapacity();
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService?.upsertOrder(updated));
    }
  }

  void setKitchenStatus(KitchenStatus status) {
    kitchenStatus = status;
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService?.setKitchenBusyMode(status == KitchenStatus.busy));
    }
  }

  void toggleKitchenBusy() {
    kitchenStatus = kitchenStatus == KitchenStatus.busy
        ? KitchenStatus.ready
        : KitchenStatus.busy;
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService
          ?.setKitchenBusyMode(kitchenStatus == KitchenStatus.busy));
    }
  }

  /// Set kitchen capacity level directly
  void setKitchenCapacity(KitchenCapacity capacity) {
    kitchenCapacity = capacity;
    notifyListeners();
  }

  /// Update kitchen capacity parameters (PRD US-009)
  void setKitchenParams(KitchenCapacityParams params) {
    kitchenParams = params;
    _recalculateCapacity();
    notifyListeners();
  }

  /// Recalculate capacity based on current orders
  void _recalculateCapacity() {
    kitchenCapacity = kitchenParams.getCapacityLevel(capacityPercent);
  }

  /// 86 an item (mark as sold out) - PRD US-002
  void set86Item(String itemId, bool is86d) {
    final index = _menuItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;
    _menuItems[index] = _menuItems[index].copyWith(is86d: is86d);
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService?.updateMenu86(itemId: itemId, is86d: is86d));
    }
  }

  /// Get list of 86'd items
  List<MenuItem> get soldOutItems =>
      _menuItems.where((item) => item.is86d || item.stock == 0).toList();

  /// Cancel an order with reason (PRD US-004)
  void cancelOrder(String orderId, String reason) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    final order = _orders[index];

    // Only return stock if not yet in progress
    if (order.status == OrderStatus.pending ||
        order.status == OrderStatus.acknowledged) {
      for (final item in order.items) {
        final menuIndex =
            _menuItems.indexWhere((m) => m.id == item.menuItem.id);
        if (menuIndex != -1) {
          _menuItems[menuIndex] = _menuItems[menuIndex].copyWith(
            stock: _menuItems[menuIndex].stock + item.quantity,
          );
        }
      }
    }

    _orders[index] = order.copyWith(
      status: OrderStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
    );
    _recalculateCapacity();
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService?.upsertOrder(_orders[index]));
    }
  }

  void deleteOrder(String orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }

    _orders.removeAt(index);
    _recalculateCapacity();
    notifyListeners();

    if (!_syncingFromRemote) {
      unawaited(_syncService?.deleteOrder(orderId));
    }
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

    if (!_syncingFromRemote) {
      unawaited(_syncService?.upsertMenuItem(item));
    }
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
    return <MenuItem>[
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

  @override
  void dispose() {
    stopRemoteSync();
    super.dispose();
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
