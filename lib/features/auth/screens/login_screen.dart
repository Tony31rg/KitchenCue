import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../services/state_management/global_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  static const String _waiterPin = '1111';
  static const String _chefPin = '2580';
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleWaiter() {
    final appState = AppStateScope.of(context);
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    if (name.isEmpty) {
      setState(() => _selectedRole = UserRole.waiter);
      return;
    }
    if (pin != _waiterPin) {
      setState(() => _selectedRole = UserRole.waiter);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid waiter PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    appState.setUserRole(UserRole.waiter);
    appState.setWaiterName(name);
    context.go(RouteConstants.dashboard);
  }

  void _handleChef() {
    final appState = AppStateScope.of(context);
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    if (name.isEmpty) {
      setState(() => _selectedRole = UserRole.chef);
      return;
    }
    if (pin != _chefPin) {
      setState(() => _selectedRole = UserRole.chef);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid chef PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    appState.setUserRole(UserRole.chef);
    appState.setWaiterName(name);
    context.go(RouteConstants.kitchenQueue);
  }

  @override
  Widget build(BuildContext context) {
    final showCredentialsInputs = _selectedRole != null;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF1E1E1E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2F2F2F)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'KITCHENCUE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.6,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'REAL-TIME RESTAURANT CAFE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (showCredentialsInputs) ...[
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      onSubmitted: (_) => _selectedRole == UserRole.chef
                          ? _handleChef()
                          : _handleWaiter(),
                      decoration: InputDecoration(
                        hintText: _selectedRole == UserRole.chef
                            ? 'Enter chef name'
                            : 'Enter waiter name',
                        hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
                        filled: true,
                        fillColor: const Color(0xFF242424),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF9800)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _selectedRole == UserRole.chef
                          ? _handleChef()
                          : _handleWaiter(),
                      decoration: InputDecoration(
                        hintText: _selectedRole == UserRole.chef
                            ? 'Enter chef PIN'
                            : 'Enter waiter PIN',
                        hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
                        filled: true,
                        fillColor: const Color(0xFF242424),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFF42A5F5)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedRole != UserRole.waiter) {
                        setState(() => _selectedRole = UserRole.waiter);
                        return;
                      }
                      _handleWaiter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                      shadowColor: Colors.orange.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'I AM A WAITER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedRole != UserRole.chef) {
                        setState(() => _selectedRole = UserRole.chef);
                        return;
                      }
                      _handleChef();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                      shadowColor: Colors.green.withValues(alpha: 0.35),
                    ),
                    child: const Text(
                      'I AM KITCHEN STAFF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
