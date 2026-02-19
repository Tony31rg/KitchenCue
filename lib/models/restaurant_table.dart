/// Enum representing table status states.
enum TableStatus {
  empty,
  occupied,
}

/// Extension to provide display properties for TableStatus.
extension TableStatusExt on TableStatus {
  /// Display name for the status.
  String get displayName {
    switch (this) {
      case TableStatus.empty:
        return 'Empty';
      case TableStatus.occupied:
        return 'Occupied';
    }
  }

  /// Color associated with the status.
  /// Green for Empty, Red for Occupied.
  String get colorHex {
    switch (this) {
      case TableStatus.empty:
        return '#4CAF50'; // Green
      case TableStatus.occupied:
        return '#F44336'; // Red
    }
  }
}

/// Represents a restaurant table in the system.
class RestaurantTable {
  /// Unique identifier for the table.
  final String id;

  /// Table number displayed to users.
  final String tableNumber;

  /// Current status of the table (Empty or Occupied).
  final TableStatus status;

  /// Number of seats at this table.
  final int seats;

  /// Optional order ID if table is occupied.
  final String? currentOrderId;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.seats,
    this.currentOrderId,
  });

  /// Factory constructor to create a RestaurantTable from JSON.
  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      tableNumber: json['tableNumber'] as String,
      status: TableStatus.values.byName(json['status'] as String),
      seats: json['seats'] as int,
      currentOrderId: json['currentOrderId'] as String?,
    );
  }

  /// Convert RestaurantTable to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status.name,
      'seats': seats,
      'currentOrderId': currentOrderId,
    };
  }

  /// Create a copy with modified fields.
  RestaurantTable copyWith({
    String? id,
    String? tableNumber,
    TableStatus? status,
    int? seats,
    String? currentOrderId,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      seats: seats ?? this.seats,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }
}
