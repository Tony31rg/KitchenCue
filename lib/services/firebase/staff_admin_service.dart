import 'package:cloud_functions/cloud_functions.dart';

import '../../models/staff_member.dart';
import '../../models/user_role.dart';

class StaffAdminService {
  StaffAdminService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<List<StaffMember>> listStaff(String sessionToken) async {
    final callable = _functions.httpsCallable('listStaff');
    final result = await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final rawList = List<Map<String, dynamic>>.from(
      (data['staff'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );
    return rawList.map(StaffMember.fromMap).toList();
  }

  Future<void> createStaff({
    required String sessionToken,
    required String displayName,
    required UserRole role,
    required String pin,
  }) async {
    final callable = _functions.httpsCallable('createStaffWithPin');
    await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
      'displayName': displayName,
      'role': role.name,
      'pin': pin,
    });
  }

  Future<void> updateStaff({
    required String sessionToken,
    required String staffId,
    required String displayName,
    required UserRole role,
    required bool active,
  }) async {
    final callable = _functions.httpsCallable('updateStaffProfile');
    await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
      'staffId': staffId,
      'displayName': displayName,
      'role': role.name,
      'active': active,
    });
  }

  Future<void> resetStaffPin({
    required String sessionToken,
    required String staffId,
    required String newPin,
  }) async {
    final callable = _functions.httpsCallable('resetStaffPin');
    await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
      'staffId': staffId,
      'newPin': newPin,
    });
  }

  Future<void> deleteStaff({
    required String sessionToken,
    required String staffId,
  }) async {
    final callable = _functions.httpsCallable('deleteStaff');
    await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
      'staffId': staffId,
    });
  }
}
