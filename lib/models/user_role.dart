/// Enum representing user roles in the KitchenCue system.
enum UserRole {
  waiter,
  kitchen,
}

/// Extension to provide display properties for UserRole.
extension UserRoleExt on UserRole {
  /// Display name for the role.
  String get displayName {
    switch (this) {
      case UserRole.waiter:
        return 'Waiter Service';
      case UserRole.kitchen:
        return 'Kitchen Staff';
    }
  }

  /// Description text for the role.
  String get description {
    switch (this) {
      case UserRole.waiter:
        return 'Take orders and manage tables';
      case UserRole.kitchen:
        return 'Prepare dishes and update status';
    }
  }

  /// Icon for the role.
  String get iconName {
    switch (this) {
      case UserRole.waiter:
        return 'restaurant';
      case UserRole.kitchen:
        return 'restaurant_menu';
    }
  }

  /// Navigation route for the role.
  String get routePath {
    switch (this) {
      case UserRole.waiter:
        return '/waiter-dashboard';
      case UserRole.kitchen:
        return '/kitchen-queue';
    }
  }

  /// Console log message for navigation.
  String get navigationMessage {
    switch (this) {
      case UserRole.waiter:
        return 'Navigating to Waiter Dashboard';
      case UserRole.kitchen:
        return 'Navigating to Kitchen Queue';
    }
  }
}
