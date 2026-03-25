# KitchenCue

A real-time inventory and order management system that prevents waiters from double-selling out-of-stock items and alerts them when the kitchen is at maximum capacity.

## Problem Statement

Waiters face the embarrassment of telling a customer their meal isn't available after the order was already taken because the kitchen hadn't updated the stock levels or was too busy to keep up.

## Solution

KitchenCue provides a shared digital dashboard where stock counts decrease instantly as orders are placed, and the kitchen can "pause" new incoming orders if they are overwhelmed.

## Core Features (MVP)

1. **Live Stock Counter** - Tracks and displays current item quantities in real-time
2. **Kitchen "Busy" Mode** - Status toggle for chefs to alert waitstaff of delays
3. **Order Queue** - Lists incoming orders with millisecond-accurate timestamps

## Tech Stack

- **Framework**: Flutter
- **State Management**: Global State (liveInventoryCount, kitchenStatus)
- **Navigation**: GoRouter
- **Architecture**: Feature-based folder structure
- **Backend**: Firebase (planned)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/
│   │   └── route_constants.dart # Navigation path constants
│   ├── routing/
│   │   └── app_router.dart      # GoRouter configuration
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── login_screen.dart
│   ├── menu_dashboard/
│   │   └── screens/
│   │       └── menu_dashboard_screen.dart
│   ├── order_management/
│   │   └── screens/
│   │       └── order_detail_screen.dart
│   └── kitchen_queue/
│       └── screens/
│           ├── kitchen_queue_screen.dart
│           └── kitchen_status_screen.dart
├── models/
│   ├── menu_item.dart
│   ├── order.dart
│   └── kitchen_status.dart
└── services/
    ├── firebase/
    └── state_management/
        └── global_state.dart
```

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android emulator, iOS simulator, or physical device

## Getting Started

### 1. Clone/Navigate to the project

```bash
cd "t:\Mini Project"
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

**On connected device/emulator:**
```bash
flutter run
```

**On Chrome (Web):**
```bash
flutter run -d chrome
```

**On Windows:**
```bash
flutter run -d windows
```

### 4. Build for release

**Android APK:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

## Current App Flow

1. **Login Screen** (`/login`) - Entry point with role selection, name, and role PIN
2. **Menu Dashboard** (`/dashboard`) - Waiter view for menu items with stock badges

## Staff Login PINs

The app currently uses fixed role-based PINs for quick internal access:

- **Waiter PIN:** `1111`
- **Chef PIN:** `2580`

How login works:

1. Choose role (`I AM A WAITER` or `I AM KITCHEN STAFF`)
2. Enter staff name
3. Enter role PIN
4. Tap the selected role button (or press Enter) to continue

## Troubleshooting

### "flutter" command not found
Ensure Flutter is installed and added to your PATH:
```bash
# Check Flutter installation
flutter doctor
```

### Dependencies not resolving
Try cleaning and re-fetching:
```bash
flutter clean
flutter pub get
```

### Hot reload not working
Press `r` in terminal or save your file. For full restart, press `R`.

## Development Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter run --release` | Run in release mode |
| `flutter build apk` | Build Android APK |
| `flutter test` | Run unit tests |
| `flutter analyze` | Run static analysis |

## Next Steps

- [ ] Implement Firebase integration for real-time sync
- [ ] Add menu item model with stock tracking
- [ ] Build Kitchen Queue screen for chefs
- [ ] Implement "Busy Mode" toggle functionality
- [ ] Add order timestamp and queue system

## License

This project is for educational purposes.

---

**KitchenCue** - Never double-book the last serving again!
