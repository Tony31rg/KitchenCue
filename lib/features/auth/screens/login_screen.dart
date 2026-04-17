import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/user_role.dart';
import '../../../services/firebase/staff_auth_service.dart';
import '../../../services/state_management/global_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final StaffAuthService _staffAuthService = StaffAuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final appState = AppStateScope.of(context);
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    if (name.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your staff name and PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _staffAuthService.loginWithPin(
        displayName: name,
        pin: pin,
        deviceInfo: 'flutter-client',
      );

      appState.setUserRole(result.staff.role);
      appState.setWaiterName(result.staff.displayName);
      appState.setSession(
        staffId: result.staff.id,
        token: result.sessionToken,
      );

      if (!mounted) return;
      if (result.staff.mustResetPin) {
        await _showChangePinDialog(result.sessionToken, pin);
      }

      if (!mounted) return;
      switch (result.staff.role) {
        case UserRole.waiter:
          context.go(RouteConstants.dashboard);
          break;
        case UserRole.kitchen:
          context.go(RouteConstants.kitchenQueue);
          break;
        case UserRole.owner:
        case UserRole.manager:
          context.go(RouteConstants.ownerStaff);
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showChangePinDialog(
    String sessionToken,
    String currentPin,
  ) async {
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Reset Your PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For security, set a new PIN before continuing.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New PIN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new PIN'),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final dialogNavigator = Navigator.of(context);
              final newPin = newPinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (newPin != confirmPin) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('PIN does not match confirmation'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _staffAuthService.changeMyPin(
                sessionToken: sessionToken,
                currentPin: currentPin,
                newPin: newPin,
              );
              if (!context.mounted) return;
              dialogNavigator.pop();
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBootstrapOwnerDialog() async {
    final nameController = TextEditingController();
    final pinController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setup First Owner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Owner name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Owner PIN (4-8 digits)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _staffAuthService.bootstrapOwner(
                  displayName: nameController.text.trim(),
                  pin: pinController.text.trim(),
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Owner created. Login with owner name and PIN.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Setup failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Create Owner'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Enter staff name',
                      hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
                      filled: true,
                      fillColor: const Color(0xFF242424),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFF9800)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Enter PIN',
                      hintStyle: const TextStyle(color: Color(0xFF8C8C8C)),
                      filled: true,
                      fillColor: const Color(0xFF242424),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF42A5F5)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                      shadowColor: Colors.orange.withValues(alpha: 0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'STAFF LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _showBootstrapOwnerDialog,
                    child: const Text('First time setup? Create owner account'),
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
