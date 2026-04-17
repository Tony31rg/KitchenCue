import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../models/staff_member.dart';
import '../../../models/user_role.dart';
import '../../../services/firebase/staff_admin_service.dart';
import '../../../services/state_management/global_state.dart';

class OwnerStaffScreen extends StatefulWidget {
  const OwnerStaffScreen({super.key});

  @override
  State<OwnerStaffScreen> createState() => _OwnerStaffScreenState();
}

class _OwnerStaffScreenState extends State<OwnerStaffScreen> {
  final StaffAdminService _staffAdminService = StaffAdminService();
  bool _isLoading = false;
  String? _error;
  List<StaffMember> _staff = const <StaffMember>[];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final appState = AppStateScope.of(context);
    if (appState.sessionToken.isEmpty) {
      setState(() {
        _error = 'Missing owner session. Please login again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _staffAdminService.listStaff(appState.sessionToken);
      if (!mounted) return;
      setState(() => _staff = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    UserRole selectedRole = UserRole.waiter;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Create Staff'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Staff name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.waiter,
                        child: Text('Waiter'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.kitchen,
                        child: Text('Kitchen'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.owner,
                        child: Text('Owner'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => selectedRole = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                        labelText: 'Temporary PIN (4-8 digits)'),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final dialogNavigator = Navigator.of(context);
                    final name = nameController.text.trim();
                    final pin = pinController.text.trim();
                    if (name.isEmpty || pin.isEmpty) {
                      return;
                    }
                    final appState = AppStateScope.of(this.context);
                    await _staffAdminService.createStaff(
                      sessionToken: appState.sessionToken,
                      displayName: name,
                      role: selectedRole,
                      pin: pin,
                    );
                    if (!context.mounted) return;
                    dialogNavigator.pop();
                    await _loadStaff();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(StaffMember member) async {
    final nameController = TextEditingController(text: member.displayName);
    UserRole selectedRole = member.role;
    bool isActive = member.isActive;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Update Staff'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Staff name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.waiter,
                        child: Text('Waiter'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.kitchen,
                        child: Text('Kitchen'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.owner,
                        child: Text('Owner'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => selectedRole = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (value) => setLocalState(() => isActive = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final dialogNavigator = Navigator.of(context);
                    final appState = AppStateScope.of(this.context);
                    await _staffAdminService.updateStaff(
                      sessionToken: appState.sessionToken,
                      staffId: member.id,
                      displayName: nameController.text.trim(),
                      role: selectedRole,
                      active: isActive,
                    );
                    if (!context.mounted) return;
                    dialogNavigator.pop();
                    await _loadStaff();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showResetPinDialog(StaffMember member) async {
    final pinController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset PIN: ${member.displayName}'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(labelText: 'New temporary PIN'),
          keyboardType: TextInputType.number,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final dialogNavigator = Navigator.of(context);
              final appState = AppStateScope.of(this.context);
              await _staffAdminService.resetStaffPin(
                sessionToken: appState.sessionToken,
                staffId: member.id,
                newPin: pinController.text.trim(),
              );
              if (!context.mounted) return;
              dialogNavigator.pop();
              await _loadStaff();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStaff(StaffMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Delete ${member.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final appState = AppStateScope.of(context);
    await _staffAdminService.deleteStaff(
      sessionToken: appState.sessionToken,
      staffId: member.id,
    );
    await _loadStaff();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Staff Management'),
        actions: [
          IconButton(
            onPressed: () {
              appState.clearSession();
              context.go(RouteConstants.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStaff,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _staff.length,
                    itemBuilder: (context, index) {
                      final member = _staff[index];
                      return Card(
                        child: ListTile(
                          title: Text(member.displayName),
                          subtitle: Text(
                            '${member.role.displayName} | ${member.isActive ? 'Active' : 'Inactive'}${member.mustResetPin ? ' | Reset PIN required' : ''}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditDialog(member);
                                  break;
                                case 'pin':
                                  _showResetPinDialog(member);
                                  break;
                                case 'delete':
                                  _deleteStaff(member);
                                  break;
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'pin', child: Text('Reset PIN')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
