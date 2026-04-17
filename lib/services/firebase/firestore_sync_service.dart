import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';

import '../../models/menu_item.dart';
import '../../models/order.dart';

class FirestoreSyncService {
  FirestoreSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _dishesCollection =>
      _firestore.collection('dishes');

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  DocumentReference<Map<String, dynamic>> get _restaurantStatusDoc =>
      _firestore.collection('settings').doc('restaurant_status');

  Future<void> ensureMenuSeeded(List<MenuItem> defaults) async {
    try {
      final snapshot = await _dishesCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final item in defaults) {
        batch.set(_dishesCollection.doc(item.id), _dishToMap(item));
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
      debugPrint(
        'Firestore seed skipped for dishes: permission denied. '
        'Log in as kitchen staff and ensure firestore.rules are deployed.',
      );
    }
  }

  Future<void> ensureKitchenConfig() async {
    try {
      final doc = await _restaurantStatusDoc.get();
      if (doc.exists) {
        return;
      }
      await _restaurantStatusDoc.set({
        'isBusy': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
      debugPrint(
        'Firestore seed skipped for settings/restaurant_status: permission denied. '
        'Only kitchen role can create this document by rules.',
      );
    }
  }

  Stream<List<MenuItem>> watchMenuItems() {
    return _dishesCollection.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => _dishFromMap(doc.id, doc.data()))
          .toList(growable: false);
      items.sort((a, b) {
        final byCategory = a.category.compareTo(b.category);
        if (byCategory != 0) {
          return byCategory;
        }
        return a.name.compareTo(b.name);
      });
      return items;
    });
  }

  Stream<List<Order>> watchOrders() {
    return _ordersCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _orderFromMap(doc.id, doc.data()))
            .toList(growable: false));
  }

  Stream<bool> watchKitchenBusyMode() {
    return _restaurantStatusDoc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return false;
      }
      return data['isBusy'] as bool? ?? false;
    });
  }

  Future<List<MenuItem>> fetchAllDishes() async {
    final snapshot = await _dishesCollection.get();
    final dishes = snapshot.docs
        .map((doc) => _dishFromMap(doc.id, doc.data()))
        .toList(growable: false);
    dishes.sort((a, b) => a.name.compareTo(b.name));
    return dishes;
  }

  Future<void> upsertMenuItem(MenuItem item) async {
    await _dishesCollection.doc(item.id).set(_dishToMap(item));
  }

  Future<void> updateMenuStock({
    required String itemId,
    required int stock,
    required bool is86d,
  }) async {
    await _dishesCollection.doc(itemId).set(
      {
        'stock_left': stock,
        'stock': stock,
        'is86d': is86d,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateMenu86({
    required String itemId,
    required bool is86d,
  }) async {
    await _dishesCollection.doc(itemId).set(
      {
        'is86d': is86d,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> upsertOrder(Order order) async {
    await _ordersCollection.doc(order.id).set(_orderToMap(order));
  }

  Future<DocumentReference<Map<String, dynamic>>> submitOrder({
    required List<Map<String, dynamic>> items,
    required int tableNumber,
  }) {
    return _ordersCollection.add({
      'items': items,
      'tableNumber': tableNumber,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
  }

  Future<void> setKitchenBusyMode(bool isBusy) async {
    await _restaurantStatusDoc.set(
      {
        'isBusy': isBusy,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Map<String, dynamic> _dishToMap(MenuItem item) {
    return {
      'name': item.name,
      'price': item.price,
      'stock_left': item.stock,
      'stock': item.stock,
      'category': item.category,
      'imageUrl': item.imageUrl,
      'is86d': item.is86d,
      'avgPrepTime': item.avgPrepTime,
      'lowStockThreshold': item.lowStockThreshold,
      'isLimitedTime': item.isLimitedTime,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MenuItem _dishFromMap(String id, Map<String, dynamic> data) {
    final stockFromStockLeft = (data['stock_left'] as num?)?.toInt();
    final stockFromStock = (data['stock'] as num?)?.toInt();
    return MenuItem(
      id: id,
      name: (data['name'] ?? '').toString(),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      stock: stockFromStockLeft ?? stockFromStock ?? 0,
      category: (data['category'] ?? 'Uncategorized').toString(),
      imageUrl: data['imageUrl']?.toString(),
      is86d: data['is86d'] as bool? ?? false,
      avgPrepTime: (data['avgPrepTime'] as num?)?.toInt() ?? 10,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
      isLimitedTime: data['isLimitedTime'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _orderToMap(Order order) {
    return {
      'tableNumber': order.tableNumber,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'status': order.status.name,
      'waiterName': order.waiterName,
      'acknowledgedAt': _timestampOrNull(order.acknowledgedAt),
      'readyAt': _timestampOrNull(order.readyAt),
      'servedAt': _timestampOrNull(order.servedAt),
      'cancelledAt': _timestampOrNull(order.cancelledAt),
      'cancellationReason': order.cancellationReason,
      'notes': order.notes,
      'items': order.items
          .map((item) => {
                'menuItemId': item.menuItem.id,
                'name': item.menuItem.name,
                'price': item.menuItem.price,
                'quantity': item.quantity,
                'modifiers': item.modifiers,
                'course': item.course,
                'notes': item.notes,
              })
          .toList(growable: false),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Order _orderFromMap(String id, Map<String, dynamic> data) {
    final rawItems = (data['items'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>();

    final items = rawItems
        .map(
          (entry) => OrderItem(
            menuItem: MenuItem(
              id: (entry['menuItemId'] ?? '').toString(),
              name: (entry['name'] ?? '').toString(),
              price: (entry['price'] as num?)?.toDouble() ?? 0,
              stock: 0,
              category: 'Unknown',
            ),
            quantity: (entry['quantity'] as num?)?.toInt() ?? 0,
            modifiers:
                (entry['modifiers'] as List<dynamic>? ?? <dynamic>[]).cast(),
            course: (entry['course'] as num?)?.toInt() ?? 1,
            notes: entry['notes']?.toString(),
          ),
        )
        .toList(growable: false);

    return Order(
      id: id,
      tableNumber: (data['tableNumber'] as num?)?.toInt() ?? 0,
      items: items,
      createdAt: _dateOrNow(data['createdAt']),
      status: _parseStatus((data['status'] ?? 'pending').toString()),
      waiterName: (data['waiterName'] ?? '').toString(),
      acknowledgedAt: _dateOrNull(data['acknowledgedAt']),
      readyAt: _dateOrNull(data['readyAt']),
      servedAt: _dateOrNull(data['servedAt']),
      cancelledAt: _dateOrNull(data['cancelledAt']),
      cancellationReason: data['cancellationReason']?.toString(),
      notes: data['notes']?.toString(),
    );
  }

  OrderStatus _parseStatus(String raw) {
    for (final value in OrderStatus.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return OrderStatus.pending;
  }

  Timestamp? _timestampOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }
    return Timestamp.fromDate(value);
  }

  DateTime _dateOrNow(dynamic value) {
    return _dateOrNull(value) ?? DateTime.now();
  }

  DateTime? _dateOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
