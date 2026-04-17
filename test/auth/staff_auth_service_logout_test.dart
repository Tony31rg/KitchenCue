import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_cue/services/firebase/staff_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  test('logout signs out from FirebaseAuth', () async {
    final auth = _MockFirebaseAuth();
    final firestore = _MockFirebaseFirestore();
    when(() => auth.signOut()).thenAnswer((_) async {});

    final service = StaffAuthService(auth: auth, firestore: firestore);
    await service.logout();

    verify(() => auth.signOut()).called(1);
  });
}
