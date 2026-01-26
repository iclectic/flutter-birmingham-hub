import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_birmingham_hub/app/router.dart';
import 'package:flutter_birmingham_hub/shared/theme/app_theme.dart';
import 'package:flutter_birmingham_hub/shared/services/firebase_service.dart';
import 'package:flutter_birmingham_hub/shared/services/analytics_service.dart';
import 'package:flutter_birmingham_hub/shared/providers/analytics_providers.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get analytics service
    final analyticsService = ref.watch(analyticsServiceProvider);
    final analyticsObserver = analyticsService.getAnalyticsObserver();
    
    return MaterialApp.router(
      title: 'Birmingham Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // Add analytics observer to the navigatorObservers
      navigatorObservers: [analyticsObserver],
    );
  }
}
