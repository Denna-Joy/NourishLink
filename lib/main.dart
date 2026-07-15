import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  // Ensure framework services are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Load preferences before bootstrapping the UI to prevent page flicker
  final sharedPreferences = await SharedPreferences.getInstance();

  // Restrict screen orientation to vertical since it is a driver-focused mobile layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const NourishLinkDriverApp(),
    ),
  );
}

class NourishLinkDriverApp extends ConsumerWidget {
  const NourishLinkDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NourishLink Driver',
      debugShowCheckedModeBanner: false,
      
      // Theme Integration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically matches device operating system theme

      // Route Configuration
      routerConfig: router,
    );
  }
}
