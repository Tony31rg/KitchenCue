import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_constants.dart';
import '../core/utils/input_decoration.dart';
import '../services/state_management/global_state.dart';
import 'header_button.dart';

class MenuAppBar extends StatelessWidget {
  const MenuAppBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.cartCount,
    required this.onCartTap,
  });

  final AppState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int cartCount;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 164,
      backgroundColor: const Color(0xFF232323),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF232323),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Waiter: ${state.waiterName}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  HeaderButton(
                    label: 'Order',
                    icon: Icons.receipt_long,
                    color: const Color(0xFFFF9800),
                    badge: cartCount > 0 ? '$cartCount' : null,
                    onTap: onCartTap,
                  ),
                  const SizedBox(width: 8),
                  HeaderButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    color: const Color(0xFF3A3A3A),
                    onTap: () {
                      state.setUserRole(null);
                      context.go(RouteConstants.login);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: inputDeco('Search dishes...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
