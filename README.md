# KitchenCue

KitchenCue is a real-time restaurant workflow app with two staff roles:

- Waiter
- Kitchen staff

The app uses Firebase Authentication and Firestore to sign in staff with pseudo-emails and role-based routing.

## Current Architecture

- Frontend: Flutter
- Navigation: GoRouter
- State: AppState (in-memory session for current runtime)
- Auth: Firebase Auth (email/password)
- Role profile: Firestore users collection
- Backend: No Cloud Functions required for login flow

## Role and Login Model

Staff accounts use pseudo-email IDs, for example:

- w01@kitchencue.com (waiter)
- c01@kitchencue.com (kitchen)

In the login screen, staff can enter either full email or short ID:

- w01
- w01@kitchencue.com

Password is the staff PIN/password managed by Firebase Auth.

After login:

- waiter -> dashboard
- kitchen -> kitchen queue

## Firebase Setup (Required)

1. Open Firebase Console for project kitchencue-a4d6d.
2. Authentication -> Sign-in method -> enable Email/Password.
3. Create staff auth users (example: w01@kitchencue.com, c01@kitchencue.com).
4. Copy each user UID from Authentication.
5. Firestore -> create collection users.
6. For each auth user, create users/{uid} document where document ID equals auth UID.
7. Add fields:
    - name (string)
    - role (string: waiter or kitchen)
    - active (bool)
    - mustResetPin (bool)
    - createdAt (timestamp)
    - updatedAt (timestamp)

Important:

- role must be waiter or kitchen.
- If users/{uid} document is missing, login is rejected.

## Firestore Rules

Rules are configured in firestore.rules with these constraints:

- users/{uid} can only be read and updated by that same authenticated uid.
- Role is restricted to waiter or kitchen.
- Role cannot be changed by the client after create.

Deploy rules with:

firebase deploy --only firestore:rules

On Windows PowerShell with script policy restrictions, use:

firebase.cmd deploy --only firestore:rules

## Run Locally

1. Install Flutter dependencies:

flutter pub get

2. Run on Chrome:

flutter run -d chrome

3. Run on Windows desktop:

flutter run -d windows

## Main App Flow

1. Landing screen
2. Login screen
3. Role-based redirect:
    - waiter -> menu dashboard
    - kitchen -> kitchen queue

Existing session restore:

- On app startup, current Firebase user is checked.
- If valid users/{uid} role profile exists and active is true, app restores session and routes automatically.

## Commands

- flutter pub get
- flutter run -d chrome
- flutter run -d windows
- flutter analyze
- flutter test

## Troubleshooting

Login failed with permission-denied:

- Check users/{uid} exists.
- Check role is waiter or kitchen.
- Check active is true.

Login failed with invalid-credential:

- Check email/ID and password in Firebase Auth.

Firebase command blocked in PowerShell:

- Use firebase.cmd instead of firebase.

## Project Notes

- Legacy owner/manager and Cloud Functions login flow were removed.
- Current app is intentionally two-role only.
