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
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleWaiter() {
    final appState = AppStateScope.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _selectedRole = UserRole.waiter);
      return;
    }
    appState.setUserRole(UserRole.waiter);
    appState.setWaiterName(name);
    context.go(RouteConstants.dashboard);
  }

  void _handleChef() {
    final appState = AppStateScope.of(context);
    appState.setUserRole(UserRole.chef);
    appState.setWaiterName('');
    context.go(RouteConstants.kitchenQueue);
  }

  @override
  Widget build(BuildContext context) {
    final showNameField = _selectedRole == UserRole.waiter;

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
                  if (showNameField) ...[
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      onSubmitted: (_) => _handleWaiter(),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
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
                  ],
                  ElevatedButton(
                    onPressed: _handleWaiter,
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
                    onPressed: _handleChef,
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
