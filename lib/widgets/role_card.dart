import 'package:flutter/material.dart';
import '../models/user_role.dart';

/// RestoSync Theme Colors
class _RestoSyncTheme {
  static const Color primary = Color(0xFF0072E3); // Blue
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF616161);
}

/// An interactive role selection card with highlight animation.
///
/// Displays a role option (Waiter or Kitchen Staff) as a large,
/// tappable card with icon, title, and description.
class RoleCard extends StatelessWidget {
  /// The user role this card represents.
  final UserRole role;

  /// Whether this card is currently selected.
  final bool isSelected;

  /// Callback function when the card is tapped.
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? _RestoSyncTheme.primary
                : _RestoSyncTheme.lightGrey,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _RestoSyncTheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? _RestoSyncTheme.primary.withOpacity(0.1)
                    : _RestoSyncTheme.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(role.iconName),
                size: 48,
                color: isSelected
                    ? _RestoSyncTheme.primary
                    : _RestoSyncTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            // Role Title
            Text(
              role.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? _RestoSyncTheme.primary
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Role Description
            Text(
              role.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _RestoSyncTheme.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Map icon name to IconData.
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      default:
        return Icons.person;
    }
  }
}
