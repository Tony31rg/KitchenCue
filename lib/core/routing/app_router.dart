import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/menu_dashboard/screens/menu_dashboard_screen.dart';
import '../../features/order_management/screens/order_detail_screen.dart';
import '../../features/kitchen_queue/screens/kitchen_queue_screen.dart';
import '../../features/kitchen_queue/screens/kitchen_status_screen.dart';
import '../../models/order.dart';
import '../../services/state_management/global_state.dart';

/// App Router configuration using GoRouter
/// Handles navigation between Waiter and Kitchen interfaces
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter create(AppState appState) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteConstants.login,
      debugLogDiagnostics: true,
      refreshListenable: appState,
      routes: [
        GoRoute(
          path: RouteConstants.login,
          name: RouteConstants.loginName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteConstants.dashboard,
          name: RouteConstants.dashboardName,
          builder: (context, state) => const MenuDashboardScreen(),
        ),
        GoRoute(
          path: RouteConstants.orderDetail,
          name: RouteConstants.orderDetailName,
          builder: (context, state) {
            final order = state.extra as Order?;
            if (order == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Order not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            GoRouter.of(context).go(RouteConstants.dashboard),
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return OrderDetailScreen(order: order);
          },
        ),
        GoRoute(
          path: RouteConstants.kitchenQueue,
          name: RouteConstants.kitchenQueueName,
          builder: (context, state) => const KitchenQueueScreen(),
        ),
        GoRoute(
          path: RouteConstants.kitchenStatus,
          name: RouteConstants.kitchenStatusName,
          builder: (context, state) => const KitchenStatusScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Route: ${state.uri.path}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go(RouteConstants.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
