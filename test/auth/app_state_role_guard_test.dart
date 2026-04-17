import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_cue/models/user_role.dart';
import 'package:kitchen_cue/services/state_management/global_state.dart';

void main() {
  group('AppState role guards', () {
    test('kitchen role can manage stock and queue', () {
      final state = AppState();
      state.setUserRole(UserRole.kitchen);

      expect(state.canManageStock, isTrue);
      expect(state.canManageKitchenQueue, isTrue);
      expect(state.canPlaceOrders, isFalse);
    });

    test('waiter role can place orders but not manage kitchen', () {
      final state = AppState();
      state.setUserRole(UserRole.waiter);

      expect(state.canManageStock, isFalse);
      expect(state.canManageKitchenQueue, isFalse);
      expect(state.canPlaceOrders, isTrue);
    });

    test('clearSession clears role and session data', () {
      final state = AppState();
      state.setUserRole(UserRole.waiter);
      state.setWaiterName('Alice');
      state.setSession(staffId: 'staff-1', token: 'token-1');

      state.clearSession();

      expect(state.userRole, isNull);
      expect(state.waiterName, isEmpty);
      expect(state.currentStaffId, isEmpty);
      expect(state.sessionToken, isEmpty);
    });
  });
}
