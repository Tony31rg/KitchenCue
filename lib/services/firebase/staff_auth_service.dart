import 'package:cloud_functions/cloud_functions.dart';

import '../../models/staff_member.dart';

class StaffLoginResult {
  const StaffLoginResult({
    required this.staff,
    required this.sessionToken,
  });

  final StaffMember staff;
  final String sessionToken;
}

class StaffAuthService {
  StaffAuthService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<StaffLoginResult> loginWithPin({
    required String displayName,
    required String pin,
    required String deviceInfo,
  }) async {
    final callable = _functions.httpsCallable('staffPinLogin');
    final result = await callable.call(<String, dynamic>{
      'displayName': displayName,
      'pin': pin,
      'deviceInfo': deviceInfo,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final staff = StaffMember.fromMap(
      Map<String, dynamic>.from(data['staff'] as Map),
    );

    return StaffLoginResult(
      staff: staff,
      sessionToken: data['sessionToken'] as String? ?? '',
    );
  }

  Future<void> changeMyPin({
    required String sessionToken,
    required String currentPin,
    required String newPin,
  }) async {
    final callable = _functions.httpsCallable('changeMyPin');
    await callable.call(<String, dynamic>{
      'sessionToken': sessionToken,
      'currentPin': currentPin,
      'newPin': newPin,
    });
  }

  Future<void> bootstrapOwner({
    required String displayName,
    required String pin,
  }) async {
    final callable = _functions.httpsCallable('bootstrapOwner');
    await callable.call(<String, dynamic>{
      'displayName': displayName,
      'pin': pin,
    });
  }
}
