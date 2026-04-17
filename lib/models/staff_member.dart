import 'package:flutter/foundation.dart';

import 'user_role.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.displayName,
    required this.role,
    required this.isActive,
    required this.mustResetPin,
  });

  final String id;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final bool mustResetPin;

  factory StaffMember.fromMap(Map<String, dynamic> data) {
    return StaffMember(
      id: data['id'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: _parseRole(data['role'] as String? ?? ''),
      isActive: data['active'] as bool? ?? true,
      mustResetPin: data['mustResetPin'] as bool? ?? false,
    );
  }

  static UserRole _parseRole(String rawRole) {
    switch (rawRole.trim().toLowerCase()) {
      case 'waiter':
        return UserRole.waiter;
      case 'kitchen':
        return UserRole.kitchen;
      default:
        debugPrint('Unknown role from backend: $rawRole');
        return UserRole.waiter;
    }
  }
}
