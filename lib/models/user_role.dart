/// Enum representing user roles in the KitchenCue system.
/// Matching PRD Section 4 Personas and Section 7.3 Security
enum UserRole {
  waiter,
  kitchen,
  manager,
  owner,
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
      case UserRole.manager:
        return 'Restaurant Manager';
      case UserRole.owner:
        return 'Restaurant Owner';
    }
  }

  /// Description text for the role.
  String get description {
    switch (this) {
      case UserRole.waiter:
        return 'Take orders and manage tables';
      case UserRole.kitchen:
        return 'Prepare dishes and update status';
      case UserRole.manager:
        return 'Manage operations and view analytics';
      case UserRole.owner:
        return 'Track business performance and costs';
    }
  }

  /// Icon for the role.
  String get iconName {
    switch (this) {
      case UserRole.waiter:
        return 'restaurant';
      case UserRole.kitchen:
        return 'restaurant_menu';
      case UserRole.manager:
        return 'manage_accounts';
      case UserRole.owner:
        return 'business';
    }
  }

  /// Navigation route for the role.
  String get routePath {
    switch (this) {
      case UserRole.waiter:
        return '/waiter-dashboard';
      case UserRole.kitchen:
        return '/kitchen-queue';
      case UserRole.manager:
        return '/manager-dashboard';
      case UserRole.owner:
        return '/owner-dashboard';
    }
  }

  /// Console log message for navigation.
  String get navigationMessage {
    switch (this) {
      case UserRole.waiter:
        return 'Navigating to Waiter Dashboard';
      case UserRole.kitchen:
        return 'Navigating to Kitchen Queue';
      case UserRole.manager:
        return 'Navigating to Manager Dashboard';
      case UserRole.owner:
        return 'Navigating to Owner Dashboard';
    }
  }

  /// Whether role has admin privileges
  bool get isAdmin => this == UserRole.manager || this == UserRole.owner;

  /// Whether role can manage stock
  bool get canManageStock =>
      this == UserRole.manager ||
      this == UserRole.owner ||
      this == UserRole.kitchen;

  /// Whether role can view analytics
  bool get canViewAnalytics =>
      this == UserRole.manager || this == UserRole.owner;

  /// Whether role can 86 items
  bool get can86Items =>
      this == UserRole.manager ||
      this == UserRole.owner ||
      this == UserRole.kitchen;
}
