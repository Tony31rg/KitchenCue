/// Kitchen Capacity Indicator matching PRD Section 6.4 (US-008)
/// | Level | Icon | Meaning | Action |
/// | Low | 🟢 | Kitchen is free (< 50% capacity) | Accept orders normally |
/// | Medium | 🟡 | Moderate (50-80% capacity) | Show estimated wait time |
/// | High | 🟠 | Near capacity (80-95% capacity) | Alert + suggest quick items |
/// | Critical | 🔴 | At capacity (> 95% capacity) | Inform customers of long wait |
enum KitchenCapacity {
  low,
  medium,
  high,
  critical,
}

extension KitchenCapacityExt on KitchenCapacity {
  String get label {
    switch (this) {
      case KitchenCapacity.low:
        return 'Ready';
      case KitchenCapacity.medium:
        return 'Moderate';
      case KitchenCapacity.high:
        return 'Near Capacity';
      case KitchenCapacity.critical:
        return 'At Capacity';
    }
  }

  String get icon {
    switch (this) {
      case KitchenCapacity.low:
        return '🟢';
      case KitchenCapacity.medium:
        return '🟡';
      case KitchenCapacity.high:
        return '🟠';
      case KitchenCapacity.critical:
        return '🔴';
    }
  }

  String get description {
    switch (this) {
      case KitchenCapacity.low:
        return 'Kitchen is free - accept orders normally';
      case KitchenCapacity.medium:
        return 'Moderate load - showing estimated wait time';
      case KitchenCapacity.high:
        return 'Near capacity - consider quick menu items';
      case KitchenCapacity.critical:
        return 'At capacity - long wait expected';
    }
  }

  /// Get color for UI
  int get colorValue {
    switch (this) {
      case KitchenCapacity.low:
        return 0xFF4CAF50; // Green
      case KitchenCapacity.medium:
        return 0xFFFFC107; // Yellow/Amber
      case KitchenCapacity.high:
        return 0xFFFF9800; // Orange
      case KitchenCapacity.critical:
        return 0xFFF44336; // Red
    }
  }

  bool get isBusy =>
      this == KitchenCapacity.high || this == KitchenCapacity.critical;

  bool get shouldWarn =>
      this == KitchenCapacity.high || this == KitchenCapacity.critical;

  bool get shouldStopOrders => this == KitchenCapacity.critical;
}

/// Kitchen capacity calculation parameters (PRD US-009)
class KitchenCapacityParams {
  const KitchenCapacityParams({
    this.numberOfStations = 3,
    this.avgTimePerDish = 10,
    this.maxConcurrentOrders = 15,
    this.bufferTime = 5,
  });

  /// Number of cooking stations
  final int numberOfStations;

  /// Average time per dish (minutes)
  final int avgTimePerDish;

  /// Maximum orders prepared simultaneously
  final int maxConcurrentOrders;

  /// Buffer time for unexpected delays (minutes)
  final int bufferTime;

  /// Calculate capacity percentage from pending orders
  /// Formula: (pending_orders × avg_time) / (stations × concurrent_limit)
  double calculateCapacityPercent(int pendingOrders, int totalPrepTime) {
    if (maxConcurrentOrders == 0 || numberOfStations == 0) return 100;
    final capacity = (totalPrepTime) /
        (numberOfStations * maxConcurrentOrders * avgTimePerDish);
    return (capacity * 100).clamp(0, 100);
  }

  /// Get capacity level from percentage
  KitchenCapacity getCapacityLevel(double percent) {
    if (percent < 50) return KitchenCapacity.low;
    if (percent < 80) return KitchenCapacity.medium;
    if (percent < 95) return KitchenCapacity.high;
    return KitchenCapacity.critical;
  }

  /// Estimate wait time in minutes
  int estimateWaitTime(int pendingOrders) {
    return ((pendingOrders * avgTimePerDish) / numberOfStations).ceil() +
        bufferTime;
  }
}

// Keep old enum for backwards compatibility
@Deprecated('Use KitchenCapacity instead')
enum KitchenStatus { ready, busy }

@Deprecated('Use KitchenCapacityExt instead')
extension KitchenStatusX on KitchenStatus {
  bool get isBusy => this == KitchenStatus.busy;
  String get label => this == KitchenStatus.busy ? 'Busy' : 'Ready';
}
