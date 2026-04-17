import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  StaffAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _defaultDomain = 'kitchencue.com';

  static String _normalizeLoginEmail(String input) {
    final raw = input.trim().toLowerCase();
    final localPart = raw.split('@').first.trim();
    return '$localPart@$_defaultDomain';
  }

  static bool _isAllowedRole(String role) {
    return role == 'waiter' || role == 'kitchen';
  }

  Future<StaffLoginResult?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _auth.signOut();
      return null;
    }

    final data = userDoc.data() ?? <String, dynamic>{};
    final role = (data['role'] ?? '').toString().toLowerCase();
    final isActive = data['active'] as bool? ?? true;
    if (!isActive || !_isAllowedRole(role)) {
      await _auth.signOut();
      return null;
    }

    final name = (data['name'] ?? '').toString().trim();
    final fallback = user.email?.split('@').first ?? 'Staff';
    final mapped = <String, dynamic>{
      'id': user.uid,
      'displayName': name.isEmpty ? fallback : name,
      'role': role,
      'active': isActive,
      'mustResetPin': data['mustResetPin'] as bool? ?? false,
    };
    final token = await user.getIdToken();

    return StaffLoginResult(
      staff: StaffMember.fromMap(mapped),
      sessionToken: token ?? '',
    );
  }

  Future<StaffLoginResult> loginWithPin({
    required String displayName,
    required String pin,
    required String deviceInfo,
  }) async {
    final email = _normalizeLoginEmail(displayName);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pin,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Invalid credentials.',
        );
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'No user profile found for this account.',
        );
      }

      final data = userDoc.data() ?? <String, dynamic>{};
      final role = (data['role'] ?? '').toString().toLowerCase();
      final isActive = data['active'] as bool? ?? true;

      if (!isActive) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Staff account is inactive.',
        );
      }

      if (!_isAllowedRole(role)) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only waiter and kitchen staff can log in.',
        );
      }

      final name = (data['name'] ?? '').toString().trim();
      final mapped = <String, dynamic>{
        'id': user.uid,
        'displayName': name.isEmpty ? displayName : name,
        'role': role,
        'active': isActive,
        'mustResetPin': data['mustResetPin'] as bool? ?? false,
      };

      final staff = StaffMember.fromMap(mapped);
      final idToken = await user.getIdToken();

      return StaffLoginResult(
        staff: staff,
        sessionToken: idToken ?? '',
      );
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (_) {
      throw FirebaseAuthException(
        code: 'internal-error',
        message: 'Unable to sign in right now. Please try again.',
      );
    }
  }

  Future<void> changeMyPin({
    required String currentPin,
    required String newPin,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Please log in again before changing PIN.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPin,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPin);

    await _firestore.collection('users').doc(user.uid).set(
      {
        'mustResetPin': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
