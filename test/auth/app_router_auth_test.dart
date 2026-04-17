import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_cue/core/constants/route_constants.dart';
import 'package:kitchen_cue/core/routing/app_router.dart';
import 'package:kitchen_cue/models/user_role.dart';

void main() {
  group('AppRouter.redirectForRole', () {
    test('redirects unauthenticated user away from protected routes', () {
      final redirect = AppRouter.redirectForRole(null, RouteConstants.dashboard);
      expect(redirect, RouteConstants.login);
    });

    test('waiter cannot enter kitchen routes', () {
      final redirect = AppRouter.redirectForRole(
        UserRole.waiter,
        RouteConstants.kitchenQueue,
      );
      expect(redirect, RouteConstants.dashboard);
    });

    test('kitchen cannot enter waiter routes', () {
      final redirect = AppRouter.redirectForRole(
        UserRole.kitchen,
        RouteConstants.dashboard,
      );
      expect(redirect, RouteConstants.kitchenQueue);
    });

    test('authenticated role is redirected from auth screen', () {
      final redirect = AppRouter.redirectForRole(
        UserRole.kitchen,
        RouteConstants.login,
      );
      expect(redirect, RouteConstants.kitchenQueue);
    });

    test('allows valid route for role', () {
      final redirect = AppRouter.redirectForRole(
        UserRole.waiter,
        RouteConstants.dashboard,
      );
      expect(redirect, isNull);
    });
  });
}
