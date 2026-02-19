import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../models/user_role.dart';
import '../../../widgets/role_card.dart';

/// RestoSync Theme Colors
class _RestoSyncTheme {
  static const Color primary = Color(0xFF0072E3); // Blue
}

/// Professional Login & Role Selection Screen for KitchenCue.
///
/// Provides an intuitive interface for staff to select their role
/// (Waiter or Kitchen Staff) and authenticate with their credentials.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Selected user role (Waiter or Kitchen Staff).
  UserRole? _selectedRole;

  /// Staff ID text controller.
  final TextEditingController _staffIdController = TextEditingController();

  /// Password text controller.
  final TextEditingController _passwordController = TextEditingController();

  /// Whether to show or hide password.
  bool _obscurePassword = true;

  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _staffIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle role selection.
  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  /// Toggle password visibility.
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Handle login button press.
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Print navigation message to console
      print(_selectedRole!.navigationMessage);

      // Navigate based on selected role
      if (_selectedRole == UserRole.waiter) {
        context.go(RouteConstants.dashboard);
      } else if (_selectedRole == UserRole.kitchen) {
        context.go(RouteConstants.kitchenQueue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Logo Placeholder
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: _RestoSyncTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: _RestoSyncTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
                const Text(
                  'KitchenCue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Real-time inventory & order management',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // Role Selection Title
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Role Selection Cards
                Row(
                  children: [
                    Expanded(
                      child: RoleCard(
                        role: UserRole.waiter,
                        isSelected: _selectedRole == UserRole.waiter,
                        onTap: () => _selectRole(UserRole.waiter),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RoleCard(
                        role: UserRole.kitchen,
                        isSelected: _selectedRole == UserRole.kitchen,
                        onTap: () => _selectRole(UserRole.kitchen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Staff ID Input
                TextFormField(
                  controller: _staffIdController,
                  decoration: InputDecoration(
                    labelText: 'Staff ID',
                    hintText: 'Enter your staff ID',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your staff ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                // Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _RestoSyncTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}