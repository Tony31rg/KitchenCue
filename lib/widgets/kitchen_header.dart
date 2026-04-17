import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_constants.dart';
import '../services/firebase/staff_auth_service.dart';
import '../services/state_management/global_state.dart';
import 'header_button.dart';
import 'stat_card.dart';

class KitchenHeader extends StatelessWidget {
  const KitchenHeader({
    super.key,
    required this.totalOrders,
    required this.pendingCount,
    required this.preparingCount,
    required this.completedCount,
  });

  final int totalOrders;
  final int pendingCount;
  final int preparingCount;
  final int completedCount;

  static final StaffAuthService _staffAuthService = StaffAuthService();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Container(
      color: const Color(0xFF232323),
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KITCHENCUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      state.waiterName.isEmpty
                          ? 'Kitchen Staff'
                          : 'Chef: ${state.waiterName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              HeaderButton(
                label: 'Kitchen Settings',
                icon: Icons.settings,
                color: const Color(0xFF2E7D32),
                onTap: () => context.go(RouteConstants.kitchenStatus),
              ),
              const SizedBox(width: 8),
              HeaderButton(
                label: 'Logout',
                icon: Icons.logout,
                color: const Color(0xFF3A3A3A),
                onTap: () async {
                  await _staffAuthService.logout();
                  state.clearSession();
                  context.go(RouteConstants.login);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total',
                  value: totalOrders,
                  color: const Color(0xFF2A2A2A),
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Pending',
                  value: pendingCount,
                  color: const Color(0xFF3B2200),
                  textColor: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Preparing',
                  value: preparingCount,
                  color: const Color(0xFF0D2B4E),
                  textColor: const Color(0xFF42A5F5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Completed',
                  value: completedCount,
                  color: const Color(0xFF1B3A1F),
                  textColor: const Color(0xFF66BB6A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
