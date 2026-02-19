import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/menu_dashboard/screens/menu_dashboard_screen.dart';
import '../../features/kitchen_queue/screens/kitchen_queue_screen.dart';
import '../../features/order_management/screens/order_detail_screen.dart';

/// App Router configuration using GoRouter
/// Handles navigation between Waiter and Kitchen interfaces
class AppRouter {
  AppRouter._();

  /// Global navigator key for accessing navigator state
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// GoRouter instance with route configurations
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.login,
    debugLogDiagnostics: true,
    routes: [
      // Login / Role Selection Route
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Waiter Dashboard Route
      GoRoute(
        path: RouteConstants.dashboard,
        name: RouteConstants.dashboardName,
        builder: (context, state) => const MenuDashboardScreen(),
      ),

      // Kitchen Queue Route
      GoRoute(
        path: RouteConstants.kitchenQueue,
        name: RouteConstants.kitchenQueueName,
        builder: (context, state) => const KitchenQueueScreen(),
      ),

      // Order Detail Route
      GoRoute(
        path: RouteConstants.orderDetail,
        name: RouteConstants.orderDetailName,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'];
          final tableNumber = state.uri.queryParameters['tableNumber'];
          return OrderDetailScreen(
            orderId: orderId,
            tableNumber: tableNumber,
          );
        },
      ),
    ],
    
    // Error handling for unknown routes
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
