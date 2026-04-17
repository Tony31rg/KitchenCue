const bcrypt = require('bcryptjs');
const admin = require('firebase-admin');
const { onCall, HttpsError } = require('firebase-functions/v2/https');

admin.initializeApp();

const db = admin.firestore();
const STAFF = 'staff';
const STAFF_SECRETS = 'staffSecrets';
const STAFF_NAME_INDEX = 'staffNameIndex';
const STAFF_SESSIONS = 'staffSessions';

function normalizeName(name) {
  return String(name || '').trim().toLowerCase().replace(/\s+/g, ' ');
}

function assertPin(pin) {
  const raw = String(pin || '').trim();
  if (!/^\d{4,8}$/.test(raw)) {
    throw new HttpsError('invalid-argument', 'PIN must be 4-8 digits.');
  }
  return raw;
}

async function verifyOwnerSession(sessionToken) {
  if (!sessionToken) {
    throw new HttpsError('unauthenticated', 'Missing session token.');
  }

  const sessionRef = db.collection(STAFF_SESSIONS).doc(sessionToken);
  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) {
    throw new HttpsError('unauthenticated', 'Session not found.');
  }

  const data = sessionSnap.data();
  const expiresAt = data.expiresAt;
  if (!expiresAt || expiresAt.toMillis() < Date.now()) {
    throw new HttpsError('unauthenticated', 'Session expired.');
  }

  if (data.role !== 'owner') {
    throw new HttpsError('permission-denied', 'Owner role required.');
  }

  return data;
}

exports.staffPinLogin = onCall(async (request) => {
  const displayName = String(request.data?.displayName || '').trim();
  const pin = assertPin(request.data?.pin);
  const deviceInfo = String(request.data?.deviceInfo || 'unknown-device');

  if (!displayName) {
    throw new HttpsError('invalid-argument', 'Display name is required.');
  }

  const normalizedName = normalizeName(displayName);
  const indexSnap = await db.collection(STAFF_NAME_INDEX).doc(normalizedName).get();
  if (!indexSnap.exists) {
    throw new HttpsError('unauthenticated', 'Invalid credentials.');
  }

  const staffId = indexSnap.data().staffId;
  const staffRef = db.collection(STAFF).doc(staffId);
  const secretRef = db.collection(STAFF_SECRETS).doc(staffId);

  const [staffSnap, secretSnap] = await Promise.all([staffRef.get(), secretRef.get()]);
  if (!staffSnap.exists || !secretSnap.exists) {
    throw new HttpsError('unauthenticated', 'Invalid credentials.');
  }

  const staff = staffSnap.data();
  const secret = secretSnap.data();

  if (!staff.active) {
    throw new HttpsError('permission-denied', 'Staff account is inactive.');
  }

  const now = Date.now();
  const lockedUntil = staff.lockedUntil?.toMillis?.() || 0;
  if (lockedUntil > now) {
    throw new HttpsError('resource-exhausted', 'Account is temporarily locked.');
  }

  const ok = await bcrypt.compare(pin, secret.pinHash || '');
  if (!ok) {
    const failedAttempts = (staff.failedAttempts || 0) + 1;
    const updates = {
      failedAttempts,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (failedAttempts >= 5) {
      updates.lockedUntil = admin.firestore.Timestamp.fromMillis(now + 15 * 60 * 1000);
      updates.failedAttempts = 0;
    }

    await staffRef.update(updates);
    throw new HttpsError('unauthenticated', 'Invalid credentials.');
  }

  const sessionToken = db.collection(STAFF_SESSIONS).doc().id;
  await Promise.all([
    staffRef.update({
      failedAttempts: 0,
      lockedUntil: null,
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      lastDeviceInfo: deviceInfo,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }),
    db.collection(STAFF_SESSIONS).doc(sessionToken).set({
      staffId,
      role: staff.role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromMillis(now + 12 * 60 * 60 * 1000),
    }),
  ]);

  return {
    sessionToken,
    staff: {
      id: staffId,
      displayName: staff.displayName,
      role: staff.role,
      active: staff.active,
      mustResetPin: staff.mustResetPin || false,
    },
  };
});

exports.bootstrapOwner = onCall(async (request) => {
  const displayName = String(request.data?.displayName || '').trim();
  const pin = assertPin(request.data?.pin);

  if (!displayName) {
    throw new HttpsError('invalid-argument', 'Display name is required.');
  }

  const ownerQuery = await db.collection(STAFF).where('role', '==', 'owner').limit(1).get();
  if (!ownerQuery.empty) {
    throw new HttpsError('already-exists', 'Owner already exists. Use owner panel to manage staff.');
  }

  const normalizedName = normalizeName(displayName);
  const indexRef = db.collection(STAFF_NAME_INDEX).doc(normalizedName);
  const indexSnap = await indexRef.get();
  if (indexSnap.exists) {
    throw new HttpsError('already-exists', 'Staff name already exists.');
  }

  const staffRef = db.collection(STAFF).doc();
  const pinHash = await bcrypt.hash(pin, 12);

  await db.runTransaction(async (tx) => {
    tx.set(staffRef, {
      displayName,
      normalizedName,
      role: 'owner',
      active: true,
      mustResetPin: false,
      failedAttempts: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(db.collection(STAFF_SECRETS).doc(staffRef.id), {
      pinHash,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(indexRef, { staffId: staffRef.id });
  });

  return { ok: true };
});

exports.changeMyPin = onCall(async (request) => {
  const sessionToken = String(request.data?.sessionToken || '').trim();
  const currentPin = assertPin(request.data?.currentPin);
  const newPin = assertPin(request.data?.newPin);

  if (currentPin === newPin) {
    throw new HttpsError('invalid-argument', 'New PIN must differ from current PIN.');
  }

  if (!sessionToken) {
    throw new HttpsError('unauthenticated', 'Missing session token.');
  }

  const sessionSnap = await db.collection(STAFF_SESSIONS).doc(sessionToken).get();
  if (!sessionSnap.exists) {
    throw new HttpsError('unauthenticated', 'Invalid session.');
  }

  const session = sessionSnap.data();
  const staffId = session.staffId;
  const secretRef = db.collection(STAFF_SECRETS).doc(staffId);
  const staffRef = db.collection(STAFF).doc(staffId);

  const secretSnap = await secretRef.get();
  if (!secretSnap.exists) {
    throw new HttpsError('failed-precondition', 'Missing PIN secret.');
  }

  const currentOk = await bcrypt.compare(currentPin, secretSnap.data().pinHash || '');
  if (!currentOk) {
    throw new HttpsError('unauthenticated', 'Current PIN is incorrect.');
  }

  const pinHash = await bcrypt.hash(newPin, 12);
  await Promise.all([
    secretRef.update({
      pinHash,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }),
    staffRef.update({
      mustResetPin: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }),
  ]);

  return { ok: true };
});

exports.listStaff = onCall(async (request) => {
  await verifyOwnerSession(String(request.data?.sessionToken || '').trim());

  const snap = await db.collection(STAFF).orderBy('displayName').get();
  const staff = snap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      displayName: data.displayName,
      role: data.role,
      active: data.active,
      mustResetPin: data.mustResetPin || false,
    };
  });

  return { staff };
});

exports.createStaffWithPin = onCall(async (request) => {
  await verifyOwnerSession(String(request.data?.sessionToken || '').trim());

  const displayName = String(request.data?.displayName || '').trim();
  const role = String(request.data?.role || '').trim().toLowerCase();
  const pin = assertPin(request.data?.pin);

  if (!displayName) {
    throw new HttpsError('invalid-argument', 'Display name is required.');
  }
  if (!['waiter', 'kitchen', 'owner'].includes(role)) {
    throw new HttpsError('invalid-argument', 'Role must be waiter, kitchen, or owner.');
  }

  const normalizedName = normalizeName(displayName);
  const indexRef = db.collection(STAFF_NAME_INDEX).doc(normalizedName);
  const indexSnap = await indexRef.get();
  if (indexSnap.exists) {
    throw new HttpsError('already-exists', 'Staff name already exists.');
  }

  const staffRef = db.collection(STAFF).doc();
  const pinHash = await bcrypt.hash(pin, 12);

  await db.runTransaction(async (tx) => {
    tx.set(staffRef, {
      displayName,
      normalizedName,
      role,
      active: true,
      mustResetPin: true,
      failedAttempts: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(db.collection(STAFF_SECRETS).doc(staffRef.id), {
      pinHash,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(indexRef, { staffId: staffRef.id });
  });

  return { staffId: staffRef.id };
});

exports.updateStaffProfile = onCall(async (request) => {
  await verifyOwnerSession(String(request.data?.sessionToken || '').trim());

  const staffId = String(request.data?.staffId || '').trim();
  const displayName = String(request.data?.displayName || '').trim();
  const role = String(request.data?.role || '').trim().toLowerCase();
  const active = !!request.data?.active;

  if (!staffId || !displayName) {
    throw new HttpsError('invalid-argument', 'staffId and displayName are required.');
  }
  if (!['waiter', 'kitchen', 'owner'].includes(role)) {
    throw new HttpsError('invalid-argument', 'Role must be waiter, kitchen, or owner.');
  }

  const staffRef = db.collection(STAFF).doc(staffId);
  const staffSnap = await staffRef.get();
  if (!staffSnap.exists) {
    throw new HttpsError('not-found', 'Staff not found.');
  }

  const oldNormalized = staffSnap.data().normalizedName;
  const newNormalized = normalizeName(displayName);

  await db.runTransaction(async (tx) => {
    if (oldNormalized !== newNormalized) {
      const newIndexRef = db.collection(STAFF_NAME_INDEX).doc(newNormalized);
      const newIndexSnap = await tx.get(newIndexRef);
      if (newIndexSnap.exists) {
        throw new HttpsError('already-exists', 'Staff name already exists.');
      }
      tx.delete(db.collection(STAFF_NAME_INDEX).doc(oldNormalized));
      tx.set(newIndexRef, { staffId });
    }

    tx.update(staffRef, {
      displayName,
      normalizedName: newNormalized,
      role,
      active,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

exports.resetStaffPin = onCall(async (request) => {
  await verifyOwnerSession(String(request.data?.sessionToken || '').trim());

  const staffId = String(request.data?.staffId || '').trim();
  const newPin = assertPin(request.data?.newPin);

  if (!staffId) {
    throw new HttpsError('invalid-argument', 'staffId is required.');
  }

  const pinHash = await bcrypt.hash(newPin, 12);
  await Promise.all([
    db.collection(STAFF_SECRETS).doc(staffId).set(
      {
        pinHash,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
    db.collection(STAFF).doc(staffId).update({
      mustResetPin: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }),
  ]);

  return { ok: true };
});

exports.deleteStaff = onCall(async (request) => {
  await verifyOwnerSession(String(request.data?.sessionToken || '').trim());

  const staffId = String(request.data?.staffId || '').trim();
  if (!staffId) {
    throw new HttpsError('invalid-argument', 'staffId is required.');
  }

  const staffRef = db.collection(STAFF).doc(staffId);
  const staffSnap = await staffRef.get();
  if (!staffSnap.exists) {
    return { ok: true };
  }

  const normalizedName = staffSnap.data().normalizedName;

  await Promise.all([
    staffRef.delete(),
    db.collection(STAFF_SECRETS).doc(staffId).delete(),
    db.collection(STAFF_NAME_INDEX).doc(normalizedName).delete(),
  ]);

  return { ok: true };
});
