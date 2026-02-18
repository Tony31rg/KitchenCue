import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KitchenCueApp());
}

/// KitchenCue - Real-time inventory and order management app
/// for restaurants to prevent double-selling and manage kitchen capacity
class KitchenCueApp extends StatelessWidget {
  const KitchenCueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KitchenCue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
